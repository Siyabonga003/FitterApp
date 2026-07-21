import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/models/notification_model.dart';
import 'package:frontend_app/services/notifications_service.dart';
import 'package:frontend_app/screens/groups/group_detail_screen.dart';
import 'package:frontend_app/utils/image_url.dart';

class NotificationsSheet extends StatefulWidget {
  final VoidCallback onClosed;

  const NotificationsSheet({required this.onClosed, super.key});

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  Future<List<NotificationModel>>? _notificationsFuture;
  bool _isMarkingAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _notificationsFuture = _fetch();
    });
  }

  Future<List<NotificationModel>> _fetch() async {
    final data = await NotificationsService.getNotifications();
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> _markAllRead() async {
    setState(() => _isMarkingAll = true);
    try {
      await NotificationsService.markAllAsRead();
      _load();
    } finally {
      if (mounted) setState(() => _isMarkingAll = false);
    }
  }

  Future<void> _onTapNotification(NotificationModel notification) async {
    if (!notification.isRead) {
      await NotificationsService.markAsRead(notification.id);
    }

    if (notification.typeCode == 'GROUP_INVITE') {
      final groupId = notification.dataField('groupId');
      if (groupId != null && mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: groupId)),
        );
        return;
      }
    }

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notifications',
                        style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _isMarkingAll ? null : _markAllRead,
                      child: _isMarkingAll
                          ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryOrange),
                      )
                          : const Text('Mark all read',
                          style: TextStyle(color: AppTheme.primaryOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<NotificationModel>>(
                  future: _notificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text('Could not load notifications.', style: TextStyle(color: AppTheme.textLight)),
                      );
                    }

                    final notifications = snapshot.data!;
                    if (notifications.isEmpty) {
                      return const Center(
                        child: Text('No notifications yet.', style: TextStyle(color: AppTheme.textLight)),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return _NotificationTile(
                          notification: n,
                          onTap: () => _onTapNotification(n),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              backgroundImage: resolveImageUrl(notification.senderProfilePicUrl) != null
                  ? NetworkImage(resolveImageUrl(notification.senderProfilePicUrl)!)
                  : null,
              child: (notification.senderProfilePicUrl == null || notification.senderProfilePicUrl!.isEmpty)
                  ? Icon(_iconFor(notification.typeCode), size: 16, color: AppTheme.primaryOrange)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 13,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                      )),
                  const SizedBox(height: 2),
                  Text(notification.body, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(notification.timeAgo, style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, left: 4),
                decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String typeCode) {
    switch (typeCode) {
      case 'GROUP_INVITE':
        return Icons.group_add_rounded;
      case 'FRIEND_REQUEST':
        return Icons.person_add_alt_1_rounded;
      case 'FRIEND_ACCEPTED':
        return Icons.people_alt_rounded;
      case 'REACTION':
        return Icons.favorite_rounded;
      case 'COMMENT':
        return Icons.chat_bubble_rounded;
      case 'BADGE_AWARDED':
        return Icons.emoji_events_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}