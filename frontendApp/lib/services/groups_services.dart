// groups_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_app/core/constants.dart';
import 'package:frontend_app/models/group_model.dart';

class GroupsApiService {
  static const String _baseUrl = '${AppConstants.backendBaseUrl}/api/v1/groups';

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<GroupModel>> fetchGroups(String userAuthToken) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers(userAuthToken));

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        return decodedData.map((item) => GroupModel.fromJson(item)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized: token missing or invalid.');
      } else {
        throw Exception('Failed to load groups: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching groups: $e');
    }
  }

  Future<GroupModel> createGroup(
      String userAuthToken, {
        required String name,
        required String description,
        required String privacy,
        double? targetDistanceKm,
      }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers(userAuthToken),
        body: json.encode({
          'name': name,
          'description': description,
          'privacy': privacy,
          'targetDistanceKm': targetDistanceKm,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GroupModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('Network error creating group: $e');
    }
  }

  Future<GroupDetailModel> fetchGroupDetail(String userAuthToken, String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$groupId'),
        headers: _headers(userAuthToken),
      );

      if (response.statusCode == 200) {
        return GroupDetailModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('Network error fetching group detail: $e');
    }
  }

  Future<void> joinGroup(String userAuthToken, String groupId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$groupId/join'),
        headers: _headers(userAuthToken),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('$e'.replaceFirst('Exception: ', ''));
    }
  }

  Future<String> createInvite(String userAuthToken, String groupId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$groupId/invites'),
        headers: _headers(userAuthToken),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return decoded['code'] as String;
      } else {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('$e'.replaceFirst('Exception: ', ''));
    }
  }

  Future<void> joinViaInviteCode(String userAuthToken, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/invites/$code/join'),
        headers: _headers(userAuthToken),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('$e'.replaceFirst('Exception: ', ''));
    }
  }

  String _extractError(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      return decoded['message'] ?? 'Request failed: ${response.statusCode}';
    } catch (_) {
      return 'Request failed: ${response.statusCode}';
    }
  }

  Future<void> inviteFriend(String userAuthToken, String groupId, String friendUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$groupId/invite-friend'),
        headers: _headers(userAuthToken),
        body: json.encode({'friendUserId': friendUserId}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractError(response));
      }
    } catch (e) {
      throw Exception('$e'.replaceFirst('Exception: ', ''));
    }
  }

  Future<void> acceptGroupInvite(String userAuthToken, String groupId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$groupId/accept-invite'),
      headers: _headers(userAuthToken),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response));
    }
  }

  Future<void> declineGroupInvite(String userAuthToken, String groupId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$groupId/decline-invite'),
      headers: _headers(userAuthToken),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response));
    }
  }
}