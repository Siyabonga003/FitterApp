import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_app/services/activity_service.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/widgets/map/app_tile_layer.dart';
import 'package:frontend_app/widgets/map/heading_location_dot.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class ActiveRunScreen extends StatefulWidget {
  final String userId;
  final String activityId;
  final int activityTypeId;

  const ActiveRunScreen({
    super.key,
    required this.userId,
    required this.activityId,
    required this.activityTypeId,
  });

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen> {
  final MapController _mapController = MapController();

  // Timer
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  bool _isStopping = false;

  // GPS tracking
  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _routePoints = [];
  LatLng? _currentPosition;

  // Metrics
  double _distanceKm = 0;
  int _calories = 0;
  double _currentPaceSecPerKm = 0;
  double _speedKmh = 0;

  // Route update throttle
  DateTime? _lastRouteUpdate;

  String _activityLabel() {
    switch (widget.activityTypeId) {
      case 1:
        return '🏃 Running';
      case 2:
        return '🚴 Cycling';
      case 3:
        return '🚶 Walking';
      default:
        return '💪 Activity';
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // update every 5 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: settings)
            .listen((position) {
          if (_isPaused || !mounted) return;

          final newPoint =
          LatLng(position.latitude, position.longitude);

          setState(() {
            // Calculate distance from last point
            if (_currentPosition != null) {
              final dist = const Distance().as(
                LengthUnit.Kilometer,
                _currentPosition!,
                newPoint,
              );
              _distanceKm += dist;

              // Pace: seconds per km
              if (position.speed > 0.5) {
                _speedKmh = position.speed * 3.6;
                _currentPaceSecPerKm =
                _speedKmh > 0 ? 3600 / _speedKmh : 0;
              }

              // Calories: rough estimate ~60 kcal/km for running
              _calories = (_distanceKm * 60).round();
            }

            _currentPosition = newPoint;
            _routePoints.add(newPoint);
            _mapController.move(newPoint, 16);
          });

          // Send route update to backend every 10 seconds
          final now = DateTime.now();
          if (_lastRouteUpdate == null ||
              now.difference(_lastRouteUpdate!).inSeconds >= 10) {
            _lastRouteUpdate = now;
            _sendRouteUpdate();
          }
        });
  }

  Future<void> _sendRouteUpdate() async {
    if (_routePoints.isEmpty) return;
    final routeJson = jsonEncode(_routePoints
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList());

    await ActivityService.updateActivity(
      widget.userId,
      widget.activityId,
      {
        'routeGeoJson': routeJson,
        'distanceKm': double.parse(_distanceKm.toStringAsFixed(3)),
        'avgPaceSecPerKm': _currentPaceSecPerKm.round(),
        'avgSpeedKmh': double.parse(_speedKmh.toStringAsFixed(2)),
        'isLive': true,
      },
    );
  }

  Future<void> _stopActivity() async {
    _timer?.cancel();
    _positionStream?.cancel();
    setState(() => _isStopping = true);

    // Final route update before ending
    await _sendRouteUpdate();

    try {
      await ActivityService.endActivity(
        widget.userId,
        widget.activityId,
        {
          'endedAt': DateTime.now().toUtc().toIso8601String(),
          'distanceKm': double.parse(_distanceKm.toStringAsFixed(3)),
          'calories': _calories,
        },
      );

      if (mounted) {
        // Small delay so badge WebSocket event arrives before pop
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Stop activity error: $e');
      if (mounted) Navigator.pop(context, false);
    }
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _formattedPace {
    if (_currentPaceSecPerKm <= 0) return "--'--\"";
    final m = _currentPaceSecPerKm ~/ 60;
    final s = (_currentPaceSecPerKm % 60).round();
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Live map with route
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ??
                  const LatLng(-12.8202, 28.2133),
              initialZoom: 16,
            ),
            children: [
              const AppTileLayer(),
              // Drawn route
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: AppTheme.primaryOrange,
                      borderColor:
                      AppTheme.primaryOrange.withOpacity(0.3),
                      borderStrokeWidth: 8,
                    ),
                  ],
                ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 90,
                      height: 90,
                      child: HeadingLocationDot(color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
            ],
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkBg.withOpacity(0.95),
                    AppTheme.darkBg.withOpacity(0),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activityLabel(),
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle,
                            color: Colors.red, size: 8),
                        SizedBox(width: 4),
                        Text('LIVE',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom metrics + controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28)),
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.08),
                        width: 1)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 52,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metrics row
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      _metricTile(
                          '📏',
                          '${_distanceKm.toStringAsFixed(2)} km',
                          'Distance'),
                      _divider(),
                      _metricTile(
                          '⚡', _formattedPace, 'Pace /km'),
                      _divider(),
                      _metricTile('🔥',
                          '$_calories kcal', 'Calories'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Controls
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause / Resume
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isPaused = !_isPaused),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                                color: Colors.white24, width: 1),
                          ),
                          child: Icon(
                            _isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: AppTheme.textWhite,
                            size: 26,
                          ),
                        ),
                      ),

                      // Stop button
                      GestureDetector(
                        onTap: _isStopping ? null : _stopActivity,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isStopping
                                ? Colors.grey
                                : AppTheme.primaryOrange,
                            boxShadow: _isStopping
                                ? null
                                : [
                              BoxShadow(
                                color: AppTheme.primaryOrange
                                    .withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: _isStopping
                              ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2)
                              : const Icon(
                            Icons.stop_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Lock screen placeholder
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                              color: Colors.white24, width: 1),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppTheme.textLight,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textLight, fontSize: 11)),
      ],
    );
  }

  Widget _divider() {
    return Container(
        height: 40,
        width: 1,
        color: Colors.white.withOpacity(0.1));
  }
}