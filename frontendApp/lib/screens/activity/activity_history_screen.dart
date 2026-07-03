import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/activity_model.dart';
import 'package:frontend_app/providers/profile_provider.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class ActivityHistoryScreen extends ConsumerWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Run History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: state.isLoading
          ? const Center(
          child: CircularProgressIndicator(
              color: AppTheme.primaryOrange))
          : state.recentActivities.isEmpty
          ? const Center(
          child: Text('No runs yet — go get moving! 🏃',
              style: TextStyle(
                  color: AppTheme.textLight, fontSize: 15)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.recentActivities.length,
        itemBuilder: (context, index) {
          final activity = state.recentActivities[index];
          return _ActivityHistoryCard(activity: activity);
        },
      ),
    );
  }
}

class _ActivityHistoryCard extends StatelessWidget {
  final Activity activity;

  const _ActivityHistoryCard({required this.activity});

  List<LatLng> _parseRoute(String? routeGeoJson) {
    if (routeGeoJson == null || routeGeoJson.isEmpty) return [];
    try {
      final List<dynamic> points = jsonDecode(routeGeoJson);
      return points
          .map((p) => LatLng(
        (p['lat'] as num).toDouble(),
        (p['lng'] as num).toDouble(),
      ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final trail = _parseRoute(null);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 140,
              child: trail.length >= 2
                  ? FlutterMap(
                options: MapOptions(
                  initialCenter: trail[trail.length ~/ 2],
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                    'com.yourapp.frontend_app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: trail,
                        strokeWidth: 3,
                        color: AppTheme.primaryOrange,
                      ),
                    ],
                  ),
                ],
              )
                  : Container(
                color: const Color(0xFF0F1923),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined,
                          color: Colors.white24, size: 32),
                      const SizedBox(height: 6),
                      const Text('No route recorded',
                          style: TextStyle(
                              color: Colors.white24,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.activityTitle,
                      style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      activity.timeAgo,
                      style: const TextStyle(
                          color: AppTheme.textLight, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statChip('📏', activity.distance),
                    _statChip('⏱️', activity.duration),
                    _statChip('⚡', activity.pace),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}