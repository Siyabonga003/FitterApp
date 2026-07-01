import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/services/auth_service.dart'; // add this
import 'package:frontend_app/services/websocket_service.dart';
import 'package:http/http.dart' as http;

class RunnerLocationNotifier extends Notifier<Map<String, RunnerLocation>> {
  final WebSocketService _wsService = WebSocketService();

  @override
  Map<String, RunnerLocation> build() {
    ref.onDispose(() => _wsService.disconnect());
    return {};
  }

  Future<void> initialize() async {
    // Fetch token from SharedPreferences — set during Keycloak login
    final authToken = await AuthService.getToken();
    if (authToken == null) {
      print('No auth token found — user may not be logged in');
      return;
    }

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

          final location = RunnerLocation.fromJson(json);
          state = {...state, location.userId: location};
        } catch (e) {
          print('Failed to parse WebSocket message: $e');
        }
      },
    );
  }

  Future<void> _loadInitialFriendLocations(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:9085/api/live/friends'),
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
    // Fetch token fresh for each request in case it was refreshed
    final authToken = await AuthService.getToken();
    if (authToken == null) return;

    await http.post(
      Uri.parse('http://10.0.2.2:9085/api/cheer/$targetUserId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
  }
}

final runnerLocationProvider =
NotifierProvider<RunnerLocationNotifier, Map<String, RunnerLocation>>(
  RunnerLocationNotifier.new,
);