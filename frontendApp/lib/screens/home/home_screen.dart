import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Session Storage Utility
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/models/activity_model.dart';
import 'package:frontend_app/widgets/activity_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = fetchActivities();
  }

  // 🌐 Production WebFlux Endpoint Integrator (Dynamic Session Mapping)
  // 🌐 Production WebFlux Endpoint Integrator (Dynamic Session Mapping)
  Future<List<Activity>> fetchActivities() async {
    try {
      // 🔐 Extract the active identity from storage
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      // 🛠️ TEMPORARY OVERRIDE OVERLAY: If no one is logged in, force a real test user ID context
      // Replace this string with a real User ID record present in your Postgres "users" table
      if (userId == null || userId.isEmpty) {
        userId = "1"; // or your backend's default UUID string format
      }

      // Live Spring Boot route customized with a verifiable user row reference
      final url = Uri.parse('http://10.0.2.2:9085/api/v1/activities/user/$userId');;
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> pagedResponse = json.decode(response.body);
        final List<dynamic> jsonList = pagedResponse['content'] ?? []; // Unpack WebFlux PagedResponse array container
        return jsonList.map((data) => Activity.fromJson(data)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to reach server: Check endpoint configuration');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER APP BAR (Search & Notifications Blueprint)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
                          const Icon(Icons.search_rounded, color: AppTheme.textLight, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Search activities...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.notifications_none_rounded, size: 26, color: isDark ? AppTheme.textWhite : AppTheme.textDark),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. DYNAMIC NETWORK ACTIVITY STREAM FEED LAYER
            Expanded(
              child: FutureBuilder<List<Activity>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon)));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.textLight),
                          const SizedBox(height: 12),
                          Text('Could not fetch live feed', style: TextStyle(color: isDark ? AppTheme.textWhite : AppTheme.textDark, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNeon),
                            onPressed: () => setState(() => _activitiesFuture = fetchActivities()),
                            child: const Text('Retry Connection', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  }

                  final activities = snapshot.data ?? [];
                  if (activities.isEmpty) {
                    return const Center(child: Text('No activities logged yet.', style: TextStyle(color: AppTheme.textLight)));
                  }

                  return RefreshIndicator(
                    color: AppTheme.primaryNeon,
                    onRefresh: () async => setState(() => _activitiesFuture = fetchActivities()),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final item = activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ActivityCard(
                            username: item.username,
                            timeAgo: item.timeAgo,
                            activityTitle: item.activityTitle,
                            distance: item.distance,
                            duration: item.duration,
                            pace: item.pace,
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
        label: Text('Start Activity', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () {},
      ),
    );
  }
}