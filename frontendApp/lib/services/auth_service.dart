import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_app/models/auth_model.dart';

class AuthService {
  // 🌐 Talk DIRECTLY to your Keycloak engine running on port 8080
  static const String keycloakTokenUrl =
      'http://10.0.2.2:8080/realms/FitterAuth/protocol/openid-connect/token';

  // 🔐 Authenticate user credentials straight against Keycloak OAuth2 guidelines
  static Future<AuthResponse?> login(String email, String password) async {
    final url = Uri.parse(keycloakTokenUrl);

    try {
      // Keycloak expects a standard x-www-form-urlencoded body for token exchanges
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': 'fitter-app', // Matches your client ID configured in Keycloak
          'grant_type': 'password',
          'username': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = jsonDecode(response.body);

        // Extract the Access Token (JWT string payload)
        final String accessToken = tokenData['access_token'];

        // 🧠 Decode JWT locally to extract sub (Keycloak User ID)
        final Map<String, dynamic> payload = _parseJwtPayload(accessToken);
        final String kcUserId = payload['sub'] ?? '';
        final String username = payload['preferred_username'] ?? email;

        // Construct your AuthResponse using the token details
        final authData = AuthResponse(
          token: accessToken,
          userId: kcUserId, // This maps to your user unique identifier string
          username: username,
        );

        // 💾 Save verified OAuth credentials into session storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authData.token);
        await prefs.setString('userId', authData.userId);
        await prefs.setString('username', authData.username);

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

  // 🛠️ Simple utility function to read information wrapped inside the JWT string
  static Map<String, dynamic> _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};

    final payload = parts[1];
    String normalized = base64Url.normalize(payload);
    String resp = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(resp);
  }
}