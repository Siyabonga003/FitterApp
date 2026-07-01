import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:frontend_app/services/websocket_service.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/providers/badge_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RunnerLocationNotifier extends Notifier<Map<String, RunnerLocation>> {
  final WebSocketService _wsService = WebSocketService();

  String _myDisplayName = '';

  @override
  Map<String, RunnerLocation> build() {
    ref.onDispose(() => _wsService.disconnect());
    return {};
  }

  Future<void> initialize() async {
    final authToken = await AuthService.getToken();
    if (authToken == null) {
      print('No auth token found — user may not be logged in');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _myDisplayName = prefs.getString('username') ?? 'me';

    await _loadInitialFriendLocations(authToken);
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

  String get myDisplayName => _myDisplayName;

  Future<void> _loadInitialFriendLocations(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.127:9085/api/live/friends'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = {
          for (final item in data)
            (item['userId'] as String): RunnerLocation.fromJson(item)
        };
      }
    } catch (e) {
      print('Failed to load initial friend locations: $e');
    }
  }

  void _handleCheerEvent(Map<String, dynamic> json) {
    print('Cheer received from: ${json['senderId']}');
  }

  Future<void> sendCheer(String targetUserId) async {
    final authToken = await AuthService.getToken();
    if (authToken == null) return;

    await http.post(
      Uri.parse('http://192.168.1.127:9085/api/cheer/$targetUserId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
  }
}

final runnerLocationProvider =
NotifierProvider<RunnerLocationNotifier, Map<String, RunnerLocation>>(
  RunnerLocationNotifier.new,
);