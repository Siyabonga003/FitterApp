import 'package:frontend_app/core/constants.dart';

String? resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '${AppConstants.backendBaseUrl}$path';
}