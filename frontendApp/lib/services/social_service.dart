import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_app/core/constants.dart';
import 'package:frontend_app/services/auth_service.dart';

class ReactionSummary {
  final int likeCount;
  final int cheerCount;
  final bool currentUserLiked;
  final bool currentUserCheered;

  ReactionSummary({
    required this.likeCount,
    required this.cheerCount,
    required this.currentUserLiked,
    required this.currentUserCheered,
  });

  factory ReactionSummary.fromJson(Map<String, dynamic> json) {
    return ReactionSummary(
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      cheerCount: (json['cheerCount'] as num?)?.toInt() ?? 0,
      currentUserLiked: json['currentUserLiked'] ?? false,
      currentUserCheered: json['currentUserCheered'] ?? false,
    );
  }
}

class CommentModel {
  final String commentId;
  final String userId;
  final String displayName;
  final String? profilePicUrl;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.displayName,
    this.profilePicUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      displayName: json['displayName'] ?? 'Unknown',
      profilePicUrl: json['profilePicUrl'] as String?,
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class ActivitySocialService {
  static const String _baseUrl = '${AppConstants.backendBaseUrl}/api/v1/activities';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<ReactionSummary?> toggleReaction(String activityId, String reactionCode) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_baseUrl/$activityId/reactions'),
      headers: headers,
      body: jsonEncode({'reactionCode': reactionCode}),
    );

    if (response.statusCode == 200) {
      return ReactionSummary.fromJson(jsonDecode(response.body));
    } else {
      print('toggleReaction failed: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  static Future<List<CommentModel>> getComments(String activityId, {int page = 0, int size = 20}) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$_baseUrl/$activityId/comments?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      return content.map((c) => CommentModel.fromJson(c)).toList();
    } else {
      print('getComments failed: ${response.statusCode}');
      return [];
    }
  }

  static Future<CommentModel?> addComment(String activityId, String content) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_baseUrl/$activityId/comments'),
      headers: headers,
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommentModel.fromJson(jsonDecode(response.body));
    } else {
      print('addComment failed: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  static Future<bool> deleteComment(String activityId, String commentId) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$activityId/comments/$commentId'),
      headers: headers,
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}