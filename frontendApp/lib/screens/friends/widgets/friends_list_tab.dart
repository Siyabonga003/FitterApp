import 'package:flutter/material.dart';
import '../../../models/friendship_model.dart';
import '../../../theme/app_theme.dart';
import 'user_card.dart';

class FriendsListTab extends StatelessWidget {
  final List<FriendshipResponse> friends;
  final Future<void> Function() onRefresh;
  final Function(String id, String name) onUnfriend;
  final Function(String id) onProfileTap;

  const FriendsListTab({
    super.key,
    required this.friends,
    required this.onRefresh,
    required this.onUnfriend,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const Center(
        child: Text(
          'No friends yet — go find some! 🏃',
          style: TextStyle(color: AppTheme.textLight, fontSize: 14),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final f = friends[index];
          return UserCard(
            initial: f.initial,
            displayName: f.displayName,
            subtitle: f.email,
            onProfileTap: () => onProfileTap(f.userId),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textLight,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => onUnfriend(f.userId, f.displayName),
              child: const Text(
                'Friends',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }
}