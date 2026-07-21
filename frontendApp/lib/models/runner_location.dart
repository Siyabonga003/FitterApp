import 'package:latlong2/latlong.dart';

class RunnerLocation {
  final String userId;
  final String displayName;
  final double latitude;
  final double longitude;
  final double paceKmPerMin;
  final double distanceKm;
  final bool sharingLive;
  final int? activityTypeId;
  final List<LatLng> trail;

  RunnerLocation({
    required this.userId,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.paceKmPerMin,
    required this.distanceKm,
    required this.sharingLive,
    this.activityTypeId,
    this.trail = const [],
  });

  factory RunnerLocation.fromJson(Map<String, dynamic> json) {
    return RunnerLocation(
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? 'Runner',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      paceKmPerMin: (json['paceKmPerMin'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      sharingLive: json['sharingLive'] ?? false,
      activityTypeId: json['activityTypeId'] as int?,
      trail: const [],
    );
  }

  RunnerLocation withNewPosition(double lat, double lng) {
    final newTrail = [...trail, LatLng(lat, lng)];
    return RunnerLocation(
      userId: userId,
      displayName: displayName,
      latitude: lat,
      longitude: lng,
      paceKmPerMin: paceKmPerMin,
      distanceKm: distanceKm,
      sharingLive: sharingLive,
      activityTypeId: activityTypeId,
      trail: newTrail,
    );
  }
  String get formattedPace {
    if (paceKmPerMin <= 0) return '--:-- /km';
    final totalSeconds = (paceKmPerMin * 60).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
}