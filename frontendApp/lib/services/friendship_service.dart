import 'dart:convert';
import 'package:frontend_app/models/friendship_model.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class FriendshipService {
  static const String _base = '${AppConstants.backendBaseUrl}/api/v1/friends';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }


  static Future<List<FriendSearchResult>> getSuggestions() async {
    try {
      final headers = await _headers();
      final response = await http.get(Uri.parse('$_base/suggestions'), headers: headers);
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((j) => FriendSearchResult.fromJson(j))
            .toList();
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
    return [];
  }

  static Future<List<FriendSearchResult>> searchUsers(String displayName) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$_base/search?displayName=${Uri.encodeComponent(displayName)}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((j) => FriendSearchResult.fromJson(j))
          .toList();
    }
    return [];
  }

  static Future<FriendshipResponse?> sendRequest(String toUserId) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_base/request/$toUserId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return FriendshipResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<FriendshipResponse?> acceptRequest(String friendshipId) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_base/accept/$friendshipId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return FriendshipResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<void> declineRequest(String friendshipId) async {
    final headers = await _headers();
    await http.delete(Uri.parse('$_base/decline/$friendshipId'), headers: headers);
  }

  static Future<void> unfriend(String friendId) async {
    final headers = await _headers();
    await http.delete(Uri.parse('$_base/unfriend/$friendId'), headers: headers);
  }

  static Future<List<FriendshipResponse>> getFriends() async {
    final headers = await _headers();
    final response = await http.get(Uri.parse(_base), headers: headers);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((j) => FriendshipResponse.fromJson(j))
          .toList();
    }
    return [];
  }

  static Future<List<FriendshipResponse>> getIncomingRequests() async {
    final headers = await _headers();
    final response = await http.get(Uri.parse('$_base/requests/incoming'), headers: headers);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((j) => FriendshipResponse.fromJson(j))
          .toList();
    }
    return [];
  }

  static Future<List<FriendshipResponse>> getOutgoingRequests() async {
    final headers = await _headers();
    final response = await http.get(Uri.parse('$_base/requests/outgoing'), headers: headers);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((j) => FriendshipResponse.fromJson(j))
          .toList();
    }
    return [];
  }
}