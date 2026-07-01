// groups_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_app/models/group_model.dart';

class GroupsApiService {
  static const String _baseUrl = 'http://192.168.1.127:8080/api/v1/groups';


  Future<List<GroupModel>> fetchGroups(String userAuthToken) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userAuthToken', // Attaches your Keycloak token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        return decodedData.map((item) => GroupModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load groups: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching groups: $e');
    }
  }
}