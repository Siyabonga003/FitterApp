class Activity {
  final String username;
  final String timeAgo;
  final String activityTitle;
  final String distance;
  final String duration;
  final String pace;

  Activity({
    required this.username,
    required this.timeAgo,
    required this.activityTitle,
    required this.distance,
    required this.duration,
    required this.pace,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      username: json['username'] ?? 'Siya', // Fallback display name
      timeAgo: json['createdAt'] ?? 'Just now', // Maps to creation date field
      activityTitle: json['activityTitle'] ?? '🏃 Running Session',
      distance: json['distance'] != null ? "${json['distance']} km" : "0.0 km",
      duration: json['duration'] != null ? "${json['duration']} min" : "0 min",
      pace: json['pace'] ?? "--:-- /km",
    );
  }
}