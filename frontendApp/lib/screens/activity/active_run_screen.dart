import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/services/activity_service.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';

class ActiveRunScreen extends ConsumerStatefulWidget {
  final String activityId;
  final String userId;
  final String activityType;

  const ActiveRunScreen({
    required this.activityId,
    required this.userId,
    required this.activityType,
    super.key,
  });

  @override
  ConsumerState<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends ConsumerState<ActiveRunScreen> {
  // Map
  final MapController _mapController = MapController();
  bool _mapReady = false;

  // GPS tracking
  LatLng? _currentPosition;
  final List<LatLng> _trail = [];
  StreamSubscription<Position>? _positionStream;

  // Stats
  Timer? _timer;
  int _secondsElapsed = 0;
  double _distanceKm = 0.0;
  int _calories = 0;
  bool _isPaused = false;
  bool _isStopping = false;

  // Pace calculation
  final List<double> _recentSpeeds = []; // m/s readings for rolling avg

  @override
  void initState() {
    super.initState();
    _initLocation();
    _startTimer();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    // Get initial position
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _trail.add(_currentPosition!);
      });
      if (_mapReady) _mapController.move(_currentPosition!, 16);
    }

    // Start listening for position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Only update if moved 5+ meters
      ),
    ).listen((Position position) {
      if (_isPaused || !mounted) return;

      final newPoint = LatLng(position.latitude, position.longitude);

      // Calculate distance from last point
      if (_currentPosition != null) {
        final distanceMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );
        _distanceKm += distanceMeters / 1000;

        // Track speed for pace calculation (m/s)
        if (position.speed > 0) {
          _recentSpeeds.add(position.speed);
          if (_recentSpeeds.length > 10) _recentSpeeds.removeAt(0);
        }

        // Estimate calories: ~60 kcal per km (rough MET estimate)
        _calories = (_distanceKm * 60).round();
      }

      setState(() {
        _currentPosition = newPoint;
        _trail.add(newPoint);
      });

      if (_mapReady) _mapController.move(newPoint, 16);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) setState(() => _secondsElapsed++);
    });
  }

  void _togglePauseResume() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _stopActivity() async {
    _timer?.cancel();
    _positionStream?.cancel();
    setState(() => _isStopping = true);

    try {
      final result = await ActivityService.endActivity(
        widget.userId,
        widget.activityId,
        {
          'endedAt': DateTime.now().toUtc().toIso8601String(),
          'distanceKm': double.parse(_distanceKm.toStringAsFixed(3)),
          'calories': _calories,
        },
      );

      if (mounted) {
        await Future.delayed(const Duration(microseconds: 800));
        Navigator.pop(context, result != null);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context, false);
    }
  }

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _formattedPace {
    if (_recentSpeeds.isEmpty || _distanceKm < 0.05) return '--:-- /km';
    final avgSpeedMs = _recentSpeeds.reduce((a, b) => a + b) / _recentSpeeds.length;
    if (avgSpeedMs <= 0) return '--:-- /km';
    final secPerKm = (1000 / avgSpeedMs).round();
    final pm = secPerKm ~/ 60;
    final ps = secPerKm % 60;
    return '$pm:${ps.toString().padLeft(2, '0')} /km';
  }

  String get _formattedDistance => _distanceKm.toStringAsFixed(2);

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? const LatLng(-12.8202, 28.2133),
                    initialZoom: 16,
                    onMapReady: () {
                      setState(() => _mapReady = true);
                      if (_currentPosition != null) {
                        _mapController.move(_currentPosition!, 16);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png?api_key=${AppConstants.stadiaMapsApiKey}',
                      userAgentPackageName: 'com.yourapp.frontend_app',
                      maxNativeZoom: 18,
                    ),
                    if (_trail.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _trail,
                            strokeWidth: 4.0,
                            color: AppTheme.primaryOrange,
                            borderColor: AppTheme.primaryOrange.withOpacity(0.3),
                            borderStrokeWidth: 8.0,
                          ),
                        ],
                      ),
                    // Current position marker
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPosition!,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF39FF14).withOpacity(0.2),
                                border: Border.all(
                                    color: const Color(0xFF39FF14).withOpacity(0.5),
                                    width: 1.5),
                              ),
                              child: Center(
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF39FF14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 48,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF39FF14),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE · ${widget.activityType.toUpperCase()}',
                          style: const TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 48,
                  right: 16,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard.withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location_rounded,
                          color: AppTheme.textWhite, size: 18),
                      onPressed: () {
                        if (_currentPosition != null && _mapReady) {
                          _mapController.move(_currentPosition!, 16);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              decoration: const BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        _isPaused ? '⏸️ SESSION PAUSED' : '⏱️ DURATION',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _isPaused ? AppTheme.primaryOrange : AppTheme.textLight,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_secondsElapsed),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 48,
                          color: _isPaused ? AppTheme.textLight : AppTheme.textWhite,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBigStat(context, '📏 DISTANCE', _formattedDistance, 'km'),
                      _buildBigStat(context, '⚡ PACE', _formattedPace.split(' ').first, '/km'),
                      _buildBigStat(context, '🔥 CALORIES', '$_calories', 'kcal'),
                    ],
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isPaused ? AppTheme.primaryOrange : Colors.white24,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isStopping ? null : _togglePauseResume,
                          child: Text(
                            _isPaused ? 'RESUME' : 'PAUSE',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _isPaused ? AppTheme.primaryOrange : AppTheme.textWhite,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.danger,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isStopping ? null : _stopActivity,
                          child: _isStopping
                              ? const CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))
                              : Text(
                            'STOP',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
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

  Widget _buildBigStat(BuildContext context, String title, String value, String unit) {
    return Column(
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textLight, fontSize: 11)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 28,
                color: AppTheme.primaryOrange,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 2),
            Text(unit,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textLight)),
          ],
        ),
      ],
    );
  }
}