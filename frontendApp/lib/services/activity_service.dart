import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_app/services/auth_service.dart';

import '../core/constants.dart';

class ActivityService {
  static const String _baseUrl = '${AppConstants.backendBaseUrl}/api/v1/activities';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<dynamic>> getActivities(String userId) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/user/$userId');

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'] ?? [];
    } else {
      print('getActivities failed: ${response.statusCode}');
      print('Body: ${response.body}');
      return [];
    }
  }

  static Future<List<dynamic>> getFriendsFeed(String userId, {int page = 0, int size = 20}) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/user/$userId/feed?page=$page&size=$size');

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'] ?? [];
    } else {
      print('getFriendsFeed failed: ${response.statusCode}');
      print('Body: ${response.body}');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getActivity(
      String userId, String activityId) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/user/$userId/$activityId');

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('getActivity failed: ${response.statusCode}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createActivity(
      String userId, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/user/$userId');

    final response = await http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('createActivity failed: ${response.statusCode}');
      print('Body: ${response.body}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateActivity(
      String userId, String activityId, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/user/$userId/$activityId');

    final response = await http
        .put(url, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('updateActivity failed: ${response.statusCode}');
      print('Body: ${response.body}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> endActivity(
      String userId, String activityId, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$_baseUrl/user/$userId/$activityId/end');

    final response = await http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('endActivity failed: ${response.statusCode}');
      print('Body: ${response.body}');
      return null;
    }
  }
}