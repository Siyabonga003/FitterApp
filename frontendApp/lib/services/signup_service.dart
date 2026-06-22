import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupService {
  static const String baseUrl = 'http://10.0.2.2:9085';

  static Future<bool> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate, // format: "yyyy-MM-dd"
    String? bio,
    int defaultActivityVisibilityId = 1,
    bool defaultRouteVisible = true,
    bool defaultLiveLocationShare = false,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/users');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
          'firstName': firstName,
          'lastName': lastName,
          'gender': gender,
          'birthDate': birthDate,
          if (bio != null) 'bio': bio,
          'defaultActivityVisibilityId': defaultActivityVisibilityId,
          'defaultRouteVisible': defaultRouteVisible,
          'defaultLiveLocationShare': defaultLiveLocationShare,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('User registration successfully processed by backend!');
        return true;
      } else {
        print('Registration failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network error during signup: $e');
      return false;
    }
  }
}