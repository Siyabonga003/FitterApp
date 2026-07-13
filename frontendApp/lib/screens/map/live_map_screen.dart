import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/providers/runner_location_provider.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final MapController _mapController = MapController();
  LatLng _initialCenter = const LatLng(-12.8202, 28.2133);
  LatLng? _myPosition;
  bool _mapReady = false;
  String _myInitial = 'M';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _setUserLocation();
      await ref.read(runnerLocationProvider.notifier).initialize();
      final name = ref.read(runnerLocationProvider.notifier).myDisplayName;
      if (mounted && name.isNotEmpty) {
        setState(() => _myInitial = name[0].toUpperCase());
      }
    });
  }

  Future<void> _setUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission denied — using Kitwe fallback');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _myPosition = LatLng(position.latitude, position.longitude);
          _initialCenter = _myPosition!;
        });
        if (_mapReady) _mapController.move(_myPosition!, 14);
      }
    } catch (e) {
      print('Could not get location: $e — using Kitwe fallback');
    }
  }

  List<Marker> _buildFriendMarkers(Map<String, RunnerLocation> locations) {
    return locations.entries
        .where((e) => e.value.sharingLive)
        .map((e) {
      final loc = e.value;
      final initial = loc.displayName.isNotEmpty
          ? loc.displayName[0].toUpperCase()
          : '?';
      return Marker(
        point: LatLng(loc.latitude, loc.longitude),
        width: 70,
        height: 70,
        child: _buildAvatarPin(
          initial: initial,
          glowColor: AppTheme.primaryOrange,
          label: loc.displayName,
        ),
      );
    })
        .toList();
  }

  List<Marker> _buildMyLocationMarker() {
    if (_myPosition == null) return [];
    return [
      Marker(
        point: _myPosition!,
        width: 70,
        height: 70,
        child: _buildAvatarPin(
          initial: _myInitial,
          glowColor: const Color(0xFF39FF14),
          label: 'You',
          isMe: true,
        ),
      ),
    ];
  }

  Widget _buildAvatarPin({
    required String initial,
    required Color glowColor,
    required String label,
    bool isMe = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor.withOpacity(0.15),
                border: Border.all(
                  color: glowColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMe
                    ? const Color(0xFF39FF14).withOpacity(0.9)
                    : AppTheme.primaryOrange,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1929).withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: glowColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  List<Polyline> _buildTrails(Map<String, RunnerLocation> locations) {
    final List<Polyline> trails = [];

    for (final entry in locations.entries) {
      final loc = entry.value;
      if (loc.trail.length < 2) continue;

      trails.add(
        Polyline(
          points: loc.trail,
          strokeWidth: 3.0,
          color: AppTheme.primaryOrange.withOpacity(0.7),
          // Dashed style to distinguish from roads
          isDotted: false,
          borderColor: AppTheme.primaryOrange.withOpacity(0.2),
          borderStrokeWidth: 6.0,
        ),
      );
    }

    return trails;
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(runnerLocationProvider);
    final liveCount = locations.values.where((l) => l.sharingLive).length;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 14,
              onMapReady: () => setState(() => _mapReady = true),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png?api_key=${AppConstants.stadiaMapsApiKey}',
                userAgentPackageName: 'com.yourapp.frontend_app',
                maxNativeZoom: 18,
              ),
              PolylineLayer(
                polylines: _buildTrails(locations),
              ),
              MarkerLayer(
                markers: _buildFriendMarkers(locations),
              ),
              MarkerLayer(
                markers: _buildMyLocationMarker(),
              ),
            ],
          ),

          Positioned(
            top: 50,
            left: 16,
            right: 80,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: AppTheme.textLight, size: 20),
                  SizedBox(width: 12),
                  Text('Find friends or routes...',
                      style: TextStyle(
                          color: AppTheme.textLight, fontSize: 14)),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 16,
            child: Column(
              children: [
                _buildMapActionButton(
                  Icons.my_location_rounded,
                  onTap: () async => await _setUserLocation(),
                ),
                const SizedBox(height: 12),
                _buildMapActionButton(Icons.layers_outlined),
              ],
            ),
          ),


          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.1), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ACTIVE FRIENDS NEARBY',
                          style: TextStyle(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8),
                        ),
                        Text(
                          '$liveCount Live Now',
                          style: const TextStyle(
                              color: AppTheme.primaryOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: locations.isEmpty
                        ? const Center(
                      child: Text(
                        'No friends running right now',
                        style: TextStyle(
                            color: AppTheme.textLight, fontSize: 13),
                      ),
                    )
                        : ListView(
                      scrollDirection: Axis.horizontal,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      children: locations.entries.map((entry) {
                        final loc = entry.value;
                        return _buildFriendPanelCard(
                          userId: loc.userId,
                          name: loc.displayName,
                          status: loc.sharingLive
                              ? 'Live now'
                              : 'Not sharing',
                          metric: loc.sharingLive
                              ? '⚡ ${loc.formattedPace}'
                              : '🏁 ${loc.formattedDistance}',
                          initial: loc.displayName.isNotEmpty
                              ? loc.displayName[0].toUpperCase()
                              : '?',
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActionButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textWhite, size: 20),
        onPressed: onTap ?? () {},
      ),
    );
  }

  Widget _buildFriendPanelCard({
    required String userId,
    required String name,
    required String status,
    required String metric,
    required String initial,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12, bottom: 20, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                child: Text(initial,
                    style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status,
                  style: const TextStyle(
                      color: AppTheme.textLight, fontSize: 11)),
              const SizedBox(height: 2),
              Text(metric,
                  style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  await ref
                      .read(runnerLocationProvider.notifier)
                      .sendCheer(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cheered $name! 👏'),
                        backgroundColor: AppTheme.primaryOrange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primaryOrange.withOpacity(0.4),
                        width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.electric_bolt_rounded,
                          color: AppTheme.primaryOrange, size: 12),
                      SizedBox(width: 3),
                      Text('Cheer',
                          style: TextStyle(
                              color: AppTheme.primaryOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}