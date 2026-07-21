import 'package:flutter/foundation.dart';
import '../models/leaderboard_user.dart';

class LeaderboardService {
  Future<List<LeaderboardUser>> fetchLeaderboard(String timeframe) async {
    await Future.delayed(const Duration(milliseconds: 900));

    return const [
      LeaderboardUser(
        id: '1',
        name: 'John Smith',
        profileImage: 'https://i.pravatar.cc/150?img=11',
        distanceKm: 368.4,
        activitiesCount: 28,
        streakDays: 18,
        rank: 1,
        trend: RankTrend.unchanged,
        isVerified: true,
        goalProgress: 1.0,
        longestRunKm: 24.5,
        avgPace: '4:15 /km',
      ),
      LeaderboardUser(
        id: '2',
        name: 'Alice Vance',
        profileImage: 'https://i.pravatar.cc/150?img=5',
        distanceKm: 344.2,
        activitiesCount: 22,
        streakDays: 14,
        rank: 2,
        trend: RankTrend.up,
        trendAmount: 1,
        isVerified: true,
        goalProgress: 0.95,
        longestRunKm: 21.1,
        avgPace: '4:30 /km',
      ),
      LeaderboardUser(
        id: '3',
        name: 'Brian Miller',
        profileImage: 'https://i.pravatar.cc/150?img=12',
        distanceKm: 319.0,
        activitiesCount: 19,
        streakDays: 9,
        rank: 3,
        trend: RankTrend.down,
        trendAmount: 1,
        goalProgress: 0.88,
        longestRunKm: 18.0,
        avgPace: '4:45 /km',
      ),
      LeaderboardUser(
        id: '4',
        name: 'Sarah Johnson',
        profileImage: 'https://i.pravatar.cc/150?img=9',
        distanceKm: 254.8,
        activitiesCount: 16,
        streakDays: 12,
        rank: 4,
        trend: RankTrend.up,
        trendAmount: 2,
        isVerified: true,
        goalProgress: 0.80,
        longestRunKm: 15.2,
        avgPace: '5:02 /km',
      ),
      LeaderboardUser(
        id: '5',
        name: 'David Koenig',
        profileImage: 'https://i.pravatar.cc/150?img=60',
        distanceKm: 230.1,
        activitiesCount: 14,
        streakDays: 5,
        rank: 5,
        trend: RankTrend.down,
        trendAmount: 2,
        goalProgress: 0.75,
        longestRunKm: 16.0,
        avgPace: '5:10 /km',
      ),
      LeaderboardUser(
        id: '6',
        name: 'Elena Rostova',
        profileImage: 'https://i.pravatar.cc/150?img=47',
        distanceKm: 210.5,
        activitiesCount: 12,
        streakDays: 7,
        rank: 6,
        trend: RankTrend.isNew,
        goalProgress: 0.68,
        longestRunKm: 12.0,
        avgPace: '5:25 /km',
      ),
    ];
  }

  Future<LeaderboardUser> fetchCurrentUser() async {
    return const LeaderboardUser(
      id: 'me',
      name: 'You',
      distanceKm: 84.6,
      activitiesCount: 9,
      streakDays: 4,
      rank: 28,
      trend: RankTrend.up,
      trendAmount: 3,
      goalProgress: 0.82,
      longestRunKm: 10.5,
      avgPace: '5:40 /km',
    );
  }
}