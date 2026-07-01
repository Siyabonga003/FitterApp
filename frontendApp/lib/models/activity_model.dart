class Activity {
  final String activityId;
  final String userId;
  final String username;
  final String timeAgo;
  final String activityTitle;
  final String distance;
  final String duration;
  final String pace;
  final int activityTypeId;
  final bool isLive;

  Activity({
    required this.activityId,
    required this.userId,
    required this.username,
    required this.timeAgo,
    required this.activityTitle,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.activityTypeId,
    required this.isLive,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    // Format distance
    final distanceKm = json['distanceKm'];
    final distanceStr = distanceKm != null
        ? '${double.tryParse(distanceKm.toString())?.toStringAsFixed(2) ?? "0.00"} km'
        : '0.00 km';

    // Format duration from seconds → m:ss or h:mm:ss
    final durationSec = json['durationSec'] as int?;
    String durationStr = '0:00';
    if (durationSec != null && durationSec > 0) {
      final h = durationSec ~/ 3600;
      final m = (durationSec % 3600) ~/ 60;
      final s = durationSec % 60;
      durationStr = h > 0
          ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
          : '$m:${s.toString().padLeft(2, '0')}';
    }

    // Format pace from sec/km → mm:ss /km
    final paceSecPerKm = json['avgPaceSecPerKm'] as int?;
    String paceStr = '--:-- /km';
    if (paceSecPerKm != null && paceSecPerKm > 0) {
      final pm = paceSecPerKm ~/ 60;
      final ps = paceSecPerKm % 60;
      paceStr = '$pm:${ps.toString().padLeft(2, '0')} /km';
    }

    // Format time ago from createdAt
    final createdAtStr = json['createdAt'] as String?;
    String timeAgo = 'Just now';
    if (createdAtStr != null) {
      try {
        final createdAt = DateTime.parse(createdAtStr);
        final diff = DateTime.now().difference(createdAt);
        if (diff.inDays > 0) {
          timeAgo = '${diff.inDays}d ago';
        } else if (diff.inHours > 0) {
          timeAgo = '${diff.inHours}h ago';
        } else if (diff.inMinutes > 0) {
          timeAgo = '${diff.inMinutes}m ago';
        }
      } catch (_) {}
    }

    // Activity type label from typeId
    final typeId = json['activityTypeId'] as int? ?? 1;

    return Activity(
      activityId: json['activityId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username'] ?? 'Unknown',
      timeAgo: timeAgo,
      activityTitle: _activityTypeLabel(typeId),
      distance: distanceStr,
      duration: durationStr,
      pace: paceStr,
      activityTypeId: typeId,
      isLive: json['isLive'] ?? false,
    );
  }

  static String _activityTypeLabel(int typeId) {
    switch (typeId) {
      case 1: return '🏃 Running';
      case 2: return '🚴 Cycling';
      case 3: return '🚶 Walking';
      case 4: return '🏊 Swimming';
      default: return '💪 Workout';
    }
  }
}