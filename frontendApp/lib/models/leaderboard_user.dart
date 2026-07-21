enum RankTrend { up, down, unchanged, isNew }

class LeaderboardUser {
  final String id;
  final String name;
  final String? profileImage;
  final double distanceKm;
  final int activitiesCount;
  final int streakDays;
  final int rank;
  final RankTrend trend;
  final int trendAmount;
  final bool isVerified;
  final double goalProgress;
  final String? city;
  final String? country;

  final double longestRunKm;
  final String avgPace;

  const LeaderboardUser({
    required this.id,
    required this.name,
    this.profileImage,
    required this.distanceKm,
    required this.activitiesCount,
    required this.streakDays,
    required this.rank,
    required this.trend,
    this.trendAmount = 0,
    this.isVerified = false,
    this.goalProgress = 1.0,
    this.city,
    this.country,
    this.longestRunKm = 0.0,
    this.avgPace = '5:30 /km',
  });
}