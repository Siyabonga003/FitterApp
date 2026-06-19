import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class ActiveRunScreen extends StatefulWidget {
  final String activityType;
  const ActiveRunScreen({required this.activityType, super.key});

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Starts or resumes the periodic execution engine
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  // Toggles between working timer execution and suspended sleep state
  void _togglePauseResume() {
    setState(() {
      if (_isPaused) {
        _isPaused = false;
        _startTimer();
      } else {
        _isPaused = true;
        _timer?.cancel();
      }
    });
  }

  // Formats total raw integer seconds into a clean 00:00:00 visual sequence
  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String hoursStr = hours.toString().padLeft(2, '0');
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  void dispose() {
    // CRITICAL: Clean up background loops to eliminate terminal navigation memory leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          // 1. TOP STATUS / GOOGLE MAP CONTAINER PLACEHOLDER
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: const Color(0xFF131C2E),
              child: const Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, size: 48, color: AppTheme.textLight),
                        SizedBox(height: 12),
                        Text(
                          'LIVE GOOGLE MAP VIEW',
                          style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. PERFORMANCE STATS READOUT PANEL
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
                  // Primary Dynamic Focus Metric: Time Duration Clock
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
                        _formatDuration(_secondsElapsed), // Directly linked to state container values
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 48,
                          color: _isPaused ? AppTheme.textLight : AppTheme.textWhite,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  // Secondary Dashboard Metrics Grid Rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBigStat(context, '📏 DISTANCE', _isPaused ? '0.0' : '3.8', 'km'),
                      _buildBigStat(context, '⚡ PACE', _isPaused ? '--:--' : '5:20', '/km'),
                      _buildBigStat(context, '🔥 CALORIES', _isPaused ? '0' : '248', 'kcal'),
                    ],
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  // 3. SYSTEM INTERACTION CONTROLS (Pause/Resume & Stop)
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _togglePauseResume,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'STOP',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
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
        Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight, fontSize: 11)),
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
            Text(unit, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight)),
          ],
        ),
      ],
    );
  }
}