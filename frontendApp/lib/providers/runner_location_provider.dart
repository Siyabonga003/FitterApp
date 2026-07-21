import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/models/badge_model.dart';
import 'package:frontend_app/providers/badge_provider.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:frontend_app/services/websocket_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RunnerLocationNotifier extends Notifier<Map<String, RunnerLocation>> {
  final WebSocketService _wsService = WebSocketService();
  String _myDisplayName = '';
  int _liveCount = 0;

  static const String _base = 'http://192.168.1.127:9085';

  @override
  Map<String, RunnerLocation> build() {
    ref.onDispose(() => _wsService.disconnect());
    return {};
  }

  Future<void> initialize() async {
    final authToken = await AuthService.getToken();
    if (authToken == null) return;

    final prefs = await SharedPreferences.getInstance();
    _myDisplayName = prefs.getString('username') ?? 'Me';

    await _loadPresence(authToken);

    _wsService.connect(
      authToken: authToken,
      onMessage: (message) {
        try {
          final json = jsonDecode(message) as Map<String, dynamic>;

          if (json['event'] == 'cheer') {
            _handleCheerEvent(json);
            return;
          }

          if (json['event'] == 'badge_awarded') {
            ref.read(badgeProvider.notifier).onBadgeAwarded(json);
            return;
          }

          final incoming = RunnerLocation.fromJson(json);
          final existing = state[incoming.userId];
          final updated = existing != null
              ? existing.withNewPosition(incoming.latitude, incoming.longitude)
              : incoming;
          state = {...state, incoming.userId: updated};
        } catch (e) {
          print('Failed to parse WebSocket message: $e');
        }
      },
    );
  }

  Future<void> _loadPresence(String authToken) async {
    try {
      final results = await Future.wait([
        http.get(
          Uri.parse('$_base/api/live/presence'),
          headers: {'Authorization': 'Bearer $authToken'},
        ),
        http.get(
          Uri.parse('$_base/api/live/presence/count'),
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      ]);

      final presenceRes = results[0];
      final countRes = results[1];

      if (presenceRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(presenceRes.body);
        state = {
          for (final item in data)
            (item['userId'] as String): RunnerLocation.fromJson(item)
        };
      } else {
        print('Presence load failed: ${presenceRes.statusCode}');
        print('Body: ${presenceRes.body}');
      }

      if (countRes.statusCode == 200) {
        _liveCount = int.tryParse(countRes.body) ?? 0;
      }
    } catch (e) {
      print('Failed to load presence: $e');
    }
  }

  Future<void> refreshFriendLocations() async {
    final authToken = await AuthService.getToken();
    if (authToken == null) return;
    await _loadPresence(authToken);
  }

  Future<void> loadFriendTrail(String userId) async {
    final authToken = await AuthService.getToken();
    if (authToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_base/api/live/friends/$userId/trail'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> points = jsonDecode(response.body);
        final trail = points.map((p) =>
            LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            )).toList();

        final existing = state[userId];
        if (existing != null && trail.isNotEmpty) {
          state = {
            ...state,
            userId: RunnerLocation(
              userId: existing.userId,
              displayName: existing.displayName,
              latitude: existing.latitude,
              longitude: existing.longitude,
              paceKmPerMin: existing.paceKmPerMin,
              distanceKm: existing.distanceKm,
              sharingLive: existing.sharingLive,
              activityTypeId: existing.activityTypeId,
              trail: trail,
            ),
          };
        }
      }
    } catch (e) {
      print('Failed to load trail for $userId: $e');
    }
  }

  void _handleCheerEvent(Map<String, dynamic> json) {
    print('Cheer received from: ${json['senderId']}');
  }

  Future<void> sendCheer(String targetUserId) async {
    final authToken = await AuthService.getToken();
    if (authToken == null) return;
    await http.post(
      Uri.parse('$_base/api/cheer/$targetUserId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
  }

  String get myDisplayName => _myDisplayName;

  int get liveCount => _liveCount;

  void publishPresence(double latitude, double longitude) {
    _wsService.sendLocationUpdate(
      latitude: latitude,
      longitude: longitude,
      pace: 0,
      distance: 0,
      sharingLive: true,
    );
  }

}

final runnerLocationProvider =
NotifierProvider<RunnerLocationNotifier, Map<String, RunnerLocation>>(
  RunnerLocationNotifier.new,
);