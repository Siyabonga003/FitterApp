import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/activity/activity_history_screen.dart';
import 'package:frontend_app/providers/badge_provider.dart';
import 'package:frontend_app/providers/profile_provider.dart';
import 'package:frontend_app/screens/friends/friends_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_app/services/profile_service.dart';
import 'package:frontend_app/utils/image_url.dart';

import 'package:frontend_app/widgets/profile/profile_header.dart';
import 'package:frontend_app/widgets/profile/metric_block.dart';
import 'package:frontend_app/widgets/profile/weekly_activity_card.dart';
import 'package:frontend_app/widgets/profile/badge_widget.dart';
import 'package:frontend_app/widgets/profile/profile_settings_sheet.dart';
import 'package:frontend_app/widgets/profile/profile_photo_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isMetric = true;
  String _displayName = '';
  String _initial = '?';
  String? _profilePicUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(badgeProvider.notifier).loadBadges();
      ref.read(profileProvider.notifier).load();
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('username') ?? '';
      if (mounted) {
        setState(() {
          _displayName = name;
          _initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        });
      }
    });
  }

  Future<void> _onTapAvatar() async {
    final pickedFile = await showProfilePhotoPicker(context);
    if (pickedFile == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) throw Exception('No active session found.');

      final relativeUrl = await ProfileService.uploadProfilePicture(userId, pickedFile);
      if (relativeUrl != null && mounted) {
        setState(() => _profilePicUrl = resolveImageUrl(relativeUrl));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo. Try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(badgeProvider);
    final profile = ref.watch(profileProvider);
    final stats = profile.stats;
    final distanceValue = _isMetric
        ? stats.totalDistanceKm.toStringAsFixed(1)
        : (stats.totalDistanceKm * 0.621371).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textWhite),
            onPressed: () => showProfileSettingsSheet(
              context,
              isMetric: _isMetric,
              onMetricChanged: (value) => setState(() => _isMetric = value),
              onEditProfile: () {},
            ),
          ),
        ],
      ),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).load(),
        color: AppTheme.primaryOrange,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 12),
            Stack(
              children: [
                ProfileHeader(
                  displayName: _displayName,
                  initial: _initial,
                  profilePicUrl: _profilePicUrl,
                  totalSessions: stats.totalSessions,
                  onTapAvatar: _onTapAvatar,
                ),
                if (_isUploadingPhoto)
                  const Positioned(
                    left: 0,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryOrange),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            Text('ALL-TIME METRICS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight, letterSpacing: 1)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricBlock(
                    title: '🏃 TOTAL DISTANCE',
                    value: distanceValue,
                    unit: _isMetric ? 'km' : 'mi',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricBlock(
                    title: '⏱️ ACTIVE TIME',
                    value: stats.formattedDuration,
                    unit: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricBlock(
                    title: '🔥 TOTAL CALORIES',
                    value: stats.totalCalories.toString(),
                    unit: 'kcal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricBlock(
                    title: '📅 WORKOUTS',
                    value: stats.totalSessions.toString(),
                    unit: 'sessions',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            WeeklyActivityCard(activeDaysThisWeek: profile.activeDaysThisWeek),
            const SizedBox(height: 28),

            Text('UNLOCKED ACHIEVEMENTS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight, letterSpacing: 1)),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: badges.isEmpty
                  ? const Center(
                  child: Text('Complete runs to unlock badges',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 13)))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return BadgeWidget(
                    emoji: badge.emoji,
                    title: badge.name,
                    isNew: badge.isNew,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.history_rounded, color: AppTheme.primaryOrange, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Run History',
                                style: TextStyle(
                                    color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              '${stats.totalSessions} runs recorded',
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendsScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.people_rounded, color: AppTheme.primaryOrange, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Text('Friends',
                            style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}