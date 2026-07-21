import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/providers/runner_location_provider.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/widgets/live_runner_card.dart';
import 'package:frontend_app/widgets/map/app_tile_layer.dart';
import 'package:frontend_app/widgets/map/heading_location_dot.dart';
import 'package:frontend_app/widgets/presence_dot.dart';
import 'package:frontend_app/widgets/user_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  LatLng _initialCenter = const LatLng(-12.8202, 28.2133);
  LatLng? _myPosition;
  bool _mapReady = false;
  String _myInitial = 'M';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      await _setUserLocation();
      await ref.read(runnerLocationProvider.notifier).initialize();
      final name = ref.read(runnerLocationProvider.notifier).myDisplayName;
      if (mounted && name.isNotEmpty) {
        setState(() => _myInitial = name[0].toUpperCase());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(runnerLocationProvider.notifier).refreshFriendLocations();
    }
  }

  Future<void> _setUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          _myPosition = LatLng(position.latitude, position.longitude);
          _initialCenter = _myPosition!;
        });
        if (_mapReady) _mapController.move(_myPosition!, 15);
        ref.read(runnerLocationProvider.notifier).publishPresence(
            position.latitude, position.longitude);
      }
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  String _activityEmoji(int? typeId) {
    switch (typeId) {
      case 1: return '🏃';
      case 2: return '🚴';
      case 3: return '🚶';
      default: return '🏃';
    }
  }

  List<Marker> _buildMyLocationMarker() {
    if (_myPosition == null) return [];
    return [
      Marker(
        point: _myPosition!,
        width: 90,
        height: 90,
        child: HeadingLocationDot(color: AppTheme.primaryOrange),
      ),
    ];
  }

  List<Marker> _buildPresenceMarkers(Map<String, RunnerLocation> locations) {
    return locations.entries.map((e) {
      final loc = e.value;
      return Marker(
        point: LatLng(loc.latitude, loc.longitude),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            ref.read(runnerLocationProvider.notifier).loadFriendTrail(loc.userId);
            showModalBottomSheet(
              context: context,
              backgroundColor: AppTheme.darkCard,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => UserBottomSheet(loc: loc),
            );
          },
          child: PresenceDot(
            initial: loc.displayName.isNotEmpty
                ? loc.displayName[0].toUpperCase() : '?',
            isActive: loc.sharingLive,
            activityEmoji:
            loc.sharingLive ? _activityEmoji(loc.activityTypeId) : '',
          ),
        ),
      );
    }).toList();
  }

  List<Polyline> _buildTrails(Map<String, RunnerLocation> locations) {
    return locations.entries
        .where((e) => e.value.trail.length >= 2)
        .map((e) => Polyline(
      points: e.value.trail,
      strokeWidth: 3.0,
      color: AppTheme.primaryOrange.withOpacity(0.7),
      borderColor: AppTheme.primaryOrange.withOpacity(0.2),
      borderStrokeWidth: 5.0,
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(runnerLocationProvider);
    final liveCount = ref.read(runnerLocationProvider.notifier).liveCount;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 15,
              onMapReady: () => setState(() => _mapReady = true),
            ),
            children: [
              const AppTileLayer(),
              PolylineLayer(polylines: _buildTrails(locations)),
              MarkerLayer(markers: _buildPresenceMarkers(locations)),
              MarkerLayer(markers: _buildMyLocationMarker()),
            ],
          ),

          // Search bar
          Positioned(
            top: 50, left: 16, right: 80,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 1),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: const Row(children: [
                Icon(Icons.search_rounded,
                    color: AppTheme.textLight, size: 20),
                SizedBox(width: 12),
                Text('Find friends or routes...',
                    style:
                    TextStyle(color: AppTheme.textLight, fontSize: 14)),
              ]),
            ),
          ),

          // Live count badge
          Positioned(
            top: 110, left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                    width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryOrange,
                    boxShadow: [BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.6),
                        blurRadius: 4, spreadRadius: 1)],
                  ),
                ),
                const SizedBox(width: 6),
                Text('$liveCount online',
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),

          // Map controls
          Positioned(
            top: 50, right: 16,
            child: Column(children: [
              _mapButton(Icons.my_location_rounded,
                  onTap: () async => await _setUserLocation()),
              const SizedBox(height: 12),
              _mapButton(Icons.refresh_rounded,
                  onTap: () => ref
                      .read(runnerLocationProvider.notifier)
                      .refreshFriendLocations()),
            ]),
          ),

          // Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.1), width: 1)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('LIVE RUNNERS NEARBY',
                            style: TextStyle(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.8)),
                        Text('$liveCount Online',
                            style: const TextStyle(
                                color: AppTheme.primaryOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: locations.isEmpty
                        ? const Center(
                        child: Text('No runners active right now',
                            style: TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 13)))
                        : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      children: locations.entries.map((e) {
                        final loc = e.value;
                        return LiveRunnerCard(
                          userId: loc.userId,
                          name: loc.displayName,
                          status: loc.sharingLive
                              ? '${_activityEmoji(loc.activityTypeId)} Running'
                              : '📍 Online',
                          metric: loc.sharingLive
                              ? '⚡ ${loc.formattedPace}'
                              : loc.formattedDistance,
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

  Widget _mapButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textWhite, size: 20),
        onPressed: onTap ?? () {},
      ),
    );
  }
}