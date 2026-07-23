import 'dart:convert';

class RoutePoint {
  final double lat;
  final double lng;

  RoutePoint({required this.lat, required this.lng});

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Activity {
  final String activityId;
  final String userId;
  final String username;
  final String? profilePicUrl;
  final String timeAgo;
  final String activityTitle;
  final String distance;
  final String duration;
  final String pace;
  final int activityTypeId;
  final bool isLive;
  final String? routeGeoJson;
  final List<RoutePoint> routePoints;
  final int likeCount;
  final int cheerCount;
  final int commentCount;
  final bool currentUserLiked;
  final bool currentUserCheered;

  Activity({
    required this.activityId,
    required this.userId,
    required this.username,
    this.profilePicUrl,
    required this.timeAgo,
    required this.activityTitle,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.activityTypeId,
    required this.isLive,
    required this.routeGeoJson,
    required this.routePoints,
    required this.likeCount,
    required this.cheerCount,
    required this.commentCount,
    required this.currentUserLiked,
    required this.currentUserCheered,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    final distanceKm = json['distanceKm'];
    final distanceStr = distanceKm != null
        ? '${double.tryParse(distanceKm.toString())?.toStringAsFixed(2) ?? "0.00"} km'
        : '0.00 km';

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

    final paceSecPerKm = json['avgPaceSecPerKm'] as int?;
    String paceStr = '--:-- /km';
    if (paceSecPerKm != null && paceSecPerKm > 0) {
      final pm = paceSecPerKm ~/ 60;
      final ps = paceSecPerKm % 60;
      paceStr = '$pm:${ps.toString().padLeft(2, '0')} /km';
    }

    final createdAtStr = json['startedAt'] as String? ?? json['createdAt'] as String?;
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

    final typeId = json['activityTypeId'] as int? ?? 1;

    final rawRouteGeoJson = json['routeGeoJson'] as String?;
    List<RoutePoint> parsedPoints = [];
    if (rawRouteGeoJson != null && rawRouteGeoJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawRouteGeoJson);
        if (decoded is List) {
          parsedPoints = decoded
              .whereType<Map<String, dynamic>>()
              .map((p) => RoutePoint.fromJson(p))
              .toList();
        }
      } catch (_) {}
    }

    return Activity(
      activityId: json['activityId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['displayName'] ?? json['username'] ?? 'Unknown',
      profilePicUrl: json['profilePicUrl'] as String?,
      timeAgo: timeAgo,
      activityTitle: _activityTypeLabel(typeId),
      distance: distanceStr,
      duration: durationStr,
      pace: paceStr,
      activityTypeId: typeId,
      isLive: json['isLive'] ?? false,
      routeGeoJson: rawRouteGeoJson,
      routePoints: parsedPoints,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      cheerCount: (json['cheerCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      currentUserLiked: json['currentUserLiked'] ?? false,
      currentUserCheered: json['currentUserCheered'] ?? false,
    );
  }

  static String _activityTypeLabel(int typeId) {
    switch (typeId) {
      case 1: return ' Running';
      case 2: return ' Jogging';
      case 3: return ' Walking';
      default: return ' Workout';
    }
  }
}

extension ActivityCopyWith on Activity {
  Activity copyWith({
    int? likeCount,
    int? cheerCount,
    int? commentCount,
    bool? currentUserLiked,
    bool? currentUserCheered,
  }) {
    return Activity(
      activityId: activityId,
      userId: userId,
      username: username,
      profilePicUrl: profilePicUrl,
      timeAgo: timeAgo,
      activityTitle: activityTitle,
      distance: distance,
      duration: duration,
      pace: pace,
      activityTypeId: activityTypeId,
      isLive: isLive,
      routeGeoJson: routeGeoJson,
      routePoints: routePoints,
      likeCount: likeCount ?? this.likeCount,
      cheerCount: cheerCount ?? this.cheerCount,
      commentCount: commentCount ?? this.commentCount,
      currentUserLiked: currentUserLiked ?? this.currentUserLiked,
      currentUserCheered: currentUserCheered ?? this.currentUserCheered,
    );
  }
}