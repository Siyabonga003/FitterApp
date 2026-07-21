import 'dart:convert';

class NotificationModel {
  final String id;
  final String? senderUserId;
  final String? senderDisplayName;
  final String? senderProfilePicUrl;
  final String typeCode;
  final String title;
  final String body;
  final String? dataJson;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.senderUserId,
    this.senderDisplayName,
    this.senderProfilePicUrl,
    required this.typeCode,
    required this.title,
    required this.body,
    this.dataJson,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notificationId']?.toString() ?? '',
      senderUserId: json['senderUserId']?.toString(),
      senderDisplayName: json['senderDisplayName'] as String?,
      senderProfilePicUrl: json['senderProfilePicUrl'] as String?,
      typeCode: json['typeCode'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      dataJson: json['dataJson'] as String?,
      isRead: json['isRead'] ?? false,
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

  /// Lazily pulls a field out of dataJson (e.g. groupId for GROUP_INVITE), or null if absent/malformed.
  String? dataField(String key) {
    if (dataJson == null || dataJson!.isEmpty) return null;
    try {
      final decoded = jsonDecode(dataJson!);
      if (decoded is Map<String, dynamic>) {
        return decoded[key]?.toString();
      }
    } catch (_) {}
    return null;
  }
}