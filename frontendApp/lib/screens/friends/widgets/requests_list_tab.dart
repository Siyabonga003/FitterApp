import 'package:flutter/material.dart';
import '../../../models/friendship_model.dart';
import '../../../theme/app_theme.dart';
import 'user_card.dart';

class RequestsListTab extends StatelessWidget {
  final List<FriendshipResponse> incoming;
  final List<FriendshipResponse> outgoing;
  final Future<void> Function() onRefresh;
  final Function(String id) onAccept;
  final Function(String id) onDecline;
  final Function(String id, String name) onCancel;
  final Function(String id) onProfileTap;
  final Widget Function(String title) sectionHeaderBuilder;

  const RequestsListTab({
    super.key,
    required this.incoming,
    required this.outgoing,
    required this.onRefresh,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
    required this.onProfileTap,
    required this.sectionHeaderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryOrange,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (incoming.isNotEmpty) ...[
            sectionHeaderBuilder('INCOMING'),
            ...incoming.map((f) => UserCard(
              initial: f.initial,
              displayName: f.displayName,
              subtitle: f.email,
              onProfileTap: () => onProfileTap(f.userId),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => onAccept(f.friendshipId),
                    child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(color: AppTheme.danger.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => onDecline(f.friendshipId),
                    child: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            )),
          ],
          if (outgoing.isNotEmpty) ...[
            const SizedBox(height: 12),
            sectionHeaderBuilder('SENT'),
            ...outgoing.map((f) => UserCard(
              initial: f.initial,
              displayName: f.displayName,
              subtitle: 'Request pending',
              onProfileTap: () => onProfileTap(f.friendId),
              trailing: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textLight,
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => onCancel(f.friendId, f.displayName),
                child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            )),
          ],
          if (incoming.isEmpty && outgoing.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text('No pending requests', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }
}