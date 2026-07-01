import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/providers/runner_location_provider.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final MapController _mapController = MapController();


  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(runnerLocationProvider.notifier).initialize());
  }

  List<Marker> _buildMarkers(Map<String, RunnerLocation> locations) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryOrange,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF1F2C42),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Name label under the pin
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                loc.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    })
        .toList();
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
            options: const MapOptions(
              initialCenter: LatLng(-26.2041, 28.0473),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourapp.frontend_app',
                maxNativeZoom: 18,
              ),
              MarkerLayer(
                markers: _buildMarkers(locations),
              ),
            ],
          ),

          // 2. FLOATING TOP SEARCH BAR
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

          // 3. FLOATING MAP CONTROLS
          Positioned(
            top: 50,
            right: 16,
            child: Column(
              children: [
                _buildMapActionButton(
                  Icons.my_location_rounded,
                  onTap: () {
                    _mapController.move(
                      const LatLng(-26.2041, 28.0473),
                      14,
                    );
                  },
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
                  // Drag handle
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
                  // Header with live count from real state
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
                  // Live friend cards — empty state if no one is running
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
              // Cheer button
              GestureDetector(
                onTap: () async {
                  await ref
                      .read(runnerLocationProvider.notifier)
                      .sendCheer(userId); // no token arg
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