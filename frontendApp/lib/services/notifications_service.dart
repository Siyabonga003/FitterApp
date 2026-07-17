import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_app/services/auth_service.dart';

class NotificationsService {
  static const String _baseUrl = 'http://192.168.1.127:9085/api/v1/notifications';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<dynamic>> getNotifications({int page = 0, int size = 20}) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl?page=$page&size=$size');

    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'] ?? [];
    } else {
      print('getNotifications failed: ${response.statusCode}');
      return [];
    }
  }

  static Future<int> getUnreadCount() async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/unread-count');

    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['count'] as num?)?.toInt() ?? 0;
    } else {
      print('getUnreadCount failed: ${response.statusCode}');
      return 0;
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/$notificationId/read');

    final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 204) {
      print('markAsRead failed: ${response.statusCode}');
    }
  }

  static Future<void> markAllAsRead() async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/read-all');

    final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 204) {
      print('markAllAsRead failed: ${response.statusCode}');
    }
  }
}