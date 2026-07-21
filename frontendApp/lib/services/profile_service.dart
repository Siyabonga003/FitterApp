import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:frontend_app/core/constants.dart';
import 'package:frontend_app/services/auth_service.dart';

class ProfileService {
  static Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('${AppConstants.backendBaseUrl}/api/v1/users/me/$userId/profile-picture');

    final mimeType = _mimeTypeFor(imageFile.path);

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final metadataId = data['metadataId'];
      if (metadataId == null) return null;
      return '/api/v1/users/me/$userId/profile-picture/$metadataId';
    } else {
      print('uploadProfilePicture failed: ${response.statusCode}');
      print('Body: ${response.body}');
      return null;
    }
  }

  static String _mimeTypeFor(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}