class ActivityStats {
  final double totalDistanceKm;
  final int totalDurationSec;
  final int totalCalories;
  final int totalSessions;

  ActivityStats({
    required this.totalDistanceKm,
    required this.totalDurationSec,
    required this.totalCalories,
    required this.totalSessions,
  });

  factory ActivityStats.fromJson(Map<String, dynamic> json) {
    return ActivityStats(
      totalDistanceKm:
      double.tryParse(json['totalDistanceKm']?.toString() ?? '0') ?? 0,
      totalDurationSec: json['totalDurationSec'] ?? 0,
      totalCalories: json['totalCalories'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
    );
  }
  
  String get formattedDuration {
    final h = totalDurationSec ~/ 3600;
    final m = (totalDurationSec % 3600) ~/ 60;
    return '${h}h ${m}m';
  }

  static ActivityStats empty() => ActivityStats(
    totalDistanceKm: 0,
    totalDurationSec: 0,
    totalCalories: 0,
    totalSessions: 0,
  );
}