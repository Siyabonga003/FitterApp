import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_app/models/auth_model.dart';

class AuthService {
  static const String keycloakTokenUrl =
      'http://10.0.2.2:8080/realms/FitterAuth/protocol/openid-connect/token';
  static const String backendBaseUrl = 'http://10.0.2.2:9085';

  static Future<AuthResponse?> login(String email, String password) async {
    final url = Uri.parse(keycloakTokenUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': 'fitter-app',
          'grant_type': 'password',
          'username': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = jsonDecode(response.body);
        final String accessToken = tokenData['access_token'];

        final Map<String, dynamic> payload = _parseJwtPayload(accessToken);
        final String kcUserId = payload['sub'] ?? '';
        final String username = payload['preferred_username'] ?? email;

        // ✅ Fetch the DB userId using the kcUserId from the JWT
        final String? dbUserId = await _fetchDbUserId(kcUserId, accessToken);

        if (dbUserId == null) {
          print('Failed to fetch DB userId for kcUserId: $kcUserId');
          return null;
        }

        final authData = AuthResponse(
          token: accessToken,
          userId: dbUserId,   // ✅ Store DB userId, not kcUserId
          username: username,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authData.token);
        await prefs.setString('userId', authData.userId);
        await prefs.setString('username', authData.username);
        await prefs.setString('kcUserId', kcUserId); // ✅ Also store kcUserId separately

        return authData;
      } else {
        print('Keycloak rejected credentials. Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Keycloak network transaction error: $e');
    }
    return null;
  }

  // ✅ Fetch the DB userId by calling the backend with the kcUserId
  static Future<String?> _fetchDbUserId(String kcUserId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$backendBaseUrl/api/v1/users/me/kc/$kcUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> user = jsonDecode(response.body);
        return user['userId'] as String?;
      } else {
        print('Failed to fetch DB userId: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching DB userId: $e');
      return null;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getKcUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('kcUserId');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('kcUserId');
  }

  static Map<String, dynamic> _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    String normalized = base64Url.normalize(payload);
    String resp = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(resp);
  }
}