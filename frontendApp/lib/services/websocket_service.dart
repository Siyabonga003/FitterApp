import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

import '../core/constants.dart';

class WebSocketService {
  StompClient? _client;
  bool _isConnected = false;

  static const String _baseUrl = AppConstants.backendBaseUrl;

  void connect({
    required String authToken,
    required void Function(String message) onMessage,
    void Function()? onConnected,
  }) {
    _client = StompClient(
      config: StompConfig(
        url: 'ws://$_baseUrl/ws/location?access_token=$authToken',
        onConnect: (frame) {
          _isConnected = true;
          print('WebSocket connected');
          onConnected?.call();
        },
        onDisconnect: (_) {
          _isConnected = false;
          print('WebSocket disconnected');
        },
        onWebSocketError: (error) => print('WebSocket error: $error'),
        onStompError: (frame) => print('STOMP error: ${frame.body}'),
        stompConnectHeaders: {'Authorization': 'Bearer $authToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $authToken'},
      ),
    );
    _client!.activate();
  }

  void sendLocationUpdate({
    required double latitude,
    required double longitude,
    required double pace,
    required double distance,
    required bool sharingLive,
  }) {
    if (!_isConnected || _client == null) return;
    _client!.send(
      destination: '/app/location.update',
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'pace': pace,
        'distance': distance,
        'sharingLive': sharingLive,
      }),
    );
  }

  void disconnect() {
    _client?.deactivate();
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}