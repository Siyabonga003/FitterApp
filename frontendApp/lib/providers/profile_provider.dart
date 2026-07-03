import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/activity_stats_model.dart';
import 'package:frontend_app/models/activity_model.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileState {
  final ActivityStats stats;
  final List<Activity> recentActivities;
  final List<int> activeDaysThisWeek; // 1=Mon ... 7=Sun
  final bool isLoading;

  ProfileState({
    required this.stats,
    required this.recentActivities,
    required this.activeDaysThisWeek,
    this.isLoading = false,
  });

  ProfileState copyWith({
    ActivityStats? stats,
    List<Activity>? recentActivities,
    List<int>? activeDaysThisWeek,
    bool? isLoading,
  }) {
    return ProfileState(
      stats: stats ?? this.stats,
      recentActivities: recentActivities ?? this.recentActivities,
      activeDaysThisWeek: activeDaysThisWeek ?? this.activeDaysThisWeek,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory ProfileState.empty() => ProfileState(
    stats: ActivityStats.empty(),
    recentActivities: [],
    activeDaysThisWeek: [],
  );
}

class ProfileNotifier extends Notifier<ProfileState> {
  static const String _base = 'http://192.168.1.127:9085/api/v1/activities';

  @override
  ProfileState build() => ProfileState.empty();

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    final token = await AuthService.getToken();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (token == null || userId == null) return;

    final headers = {'Authorization': 'Bearer $token'};
    
    final results = await Future.wait([
      http.get(Uri.parse('$_base/user/$userId/stats'), headers: headers),
      http.get(Uri.parse('$_base/user/$userId'), headers: headers),
      http.get(Uri.parse('$_base/user/$userId/active-days'), headers: headers),
    ]);

    final statsRes = results[0];
    final activitiesRes = results[1];
    final daysRes = results[2];

    final stats = statsRes.statusCode == 200
        ? ActivityStats.fromJson(jsonDecode(statsRes.body))
        : ActivityStats.empty();

    final activities = activitiesRes.statusCode == 200
        ? (jsonDecode(activitiesRes.body)['content'] as List<dynamic>? ?? [])
        .map((j) => Activity.fromJson(j))
        .toList()
        : <Activity>[];

    final activeDays = daysRes.statusCode == 200
        ? (jsonDecode(daysRes.body) as List<dynamic>)
        .map((d) => d as int)
        .toList()
        : <int>[];

    state = ProfileState(
      stats: stats,
      recentActivities: activities,
      activeDaysThisWeek: activeDays,
      isLoading: false,
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);