import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/models/activity_model.dart';
import 'package:frontend_app/widgets/activity_card.dart';
import 'package:frontend_app/services/activity_service.dart';
import 'package:frontend_app/services/notifications_service.dart';
import 'package:frontend_app/screens/activity/create_activity_screen.dart';
import 'package:frontend_app/screens/leaderboard/leaderboard_screen.dart';
import 'package:frontend_app/widgets/notifications_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Activity>> _activitiesFuture;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = fetchFriendsFeed();
    _loadUnreadCount();
  }

  Future<List<Activity>> fetchFriendsFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      throw Exception('No userId found in session — please log in again');
    }

    final List<dynamic> data = await ActivityService.getFriendsFeed(userId);
    return data.map((json) => Activity.fromJson(json)).toList();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationsService.getUnreadCount();
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsSheet(onClosed: _loadUnreadCount),
    ).whenComplete(_loadUnreadCount);
  }

  void _openLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppTheme.textLight, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search activities...',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: Icon(
                      Icons.emoji_events_outlined,
                      size: 22,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                    onPressed: _openLeaderboard,
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                          color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                        ),
                        onPressed: _openNotifications,
                      ),
                      if (_unreadCount > 0)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? AppTheme.darkBg : AppTheme.lightBg, width: 1.5),
                            ),
                            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                            child: Text(
                              _unreadCount > 9 ? '9+' : '$_unreadCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Activity>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.textLight),
                          const SizedBox(height: 12),
                          Text(
                            'Could not fetch live feed',
                            style: TextStyle(
                              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNeon),
                            onPressed: () => setState(() {
                              _activitiesFuture = fetchFriendsFeed();
                            }),
                            child: const Text(
                              'Retry Connection',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final activities = snapshot.data ?? [];
                  if (activities.isEmpty) {
                    return const Center(
                      child: Text('No activity from your friends yet.', style: TextStyle(color: AppTheme.textLight)),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.primaryNeon,
                    onRefresh: () async => setState(() {
                      _activitiesFuture = fetchFriendsFeed();
                    }),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final item = activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ActivityCard(
                            username: item.username,
                            profilePicUrl: item.profilePicUrl,
                            timeAgo: item.timeAgo,
                            activityTitle: item.activityTitle,
                            distance: item.distance,
                            duration: item.duration,
                            pace: item.pace,
                            routePoints: item.routePoints,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNeon,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text(
          'Start Activity',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
          );
          if (created == true) {
            setState(() {
              _activitiesFuture = fetchFriendsFeed();
            });
          }
        },
      ),
    );
  }
}