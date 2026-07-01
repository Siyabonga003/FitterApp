import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketService {
  StompClient? _client;
  bool _isConnected = false;

  // Replace with your actual server IP — use 10.0.2.2 for Android emulator,
  // your local IP (e.g. 192.168.x.x) for a physical device
  static const String _baseWsUrl = 'ws://10.0.2.2:9085/ws/location';

  void connect({
    required String authToken,
    required void Function(String message) onMessage,
    void Function()? onConnected,
  }) {
    _client = StompClient(
      config: StompConfig(
        url: _baseWsUrl,
        onConnect: (frame) {
          _isConnected = true;
          onConnected?.call();
        },
        onDisconnect: (_) => _isConnected = false,
        onWebSocketError: (error) => print('WebSocket error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $authToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $authToken'},
        // Receive raw text frames from the server
        onStompError: (frame) => print('STOMP error: ${frame.body}'),
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