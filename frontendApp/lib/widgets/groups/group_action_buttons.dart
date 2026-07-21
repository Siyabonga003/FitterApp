import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../theme/app_theme.dart';

class GroupActionButtons extends StatelessWidget {
  final GroupDetailModel detail;
  final bool isBusy;
  final VoidCallback onJoin;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onInvite;

  const GroupActionButtons({
    super.key,
    required this.detail,
    required this.isBusy,
    required this.onJoin,
    required this.onAccept,
    required this.onDecline,
    required this.onInvite,
  });

  static Widget smallButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool filled = true,
    bool busy = false,
  }) {
    final child = busy
        ? SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: filled ? Colors.black : AppTheme.primaryNeon,
      ),
    )
        : Text(
      label,
      style: TextStyle(
        color: filled ? Colors.black : AppTheme.primaryNeon,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );

    if (filled) {
      return SizedBox(
        height: 38,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryNeon,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: icon != null ? Icon(icon, size: 16, color: Colors.black) : const SizedBox.shrink(),
          label: child,
          onPressed: onPressed,
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.primaryNeon, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: icon != null ? Icon(icon, size: 16, color: AppTheme.primaryNeon) : const SizedBox.shrink(),
        label: child,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.hasPendingInvite)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You've been invited to this group",
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    smallButton(label: 'Accept', onPressed: isBusy ? null : onAccept, busy: isBusy),
                    const SizedBox(width: 10),
                    smallButton(label: 'Decline', filled: false, onPressed: isBusy ? null : onDecline),
                  ],
                ),
              ],
            ),
          ),

        if (!detail.isCurrentUserMember && !detail.hasPendingInvite && detail.privacyCode == 'OPEN')
          smallButton(label: 'Join Group', onPressed: isBusy ? null : onJoin, busy: isBusy),

        if (!detail.isCurrentUserMember && !detail.hasPendingInvite && detail.privacyCode != 'OPEN')
          const Text(
            'This group requires an invite to join.',
            style: TextStyle(color: AppTheme.textLight, fontStyle: FontStyle.italic, fontSize: 13),
          ),

        if (detail.canInvite) ...[
          const SizedBox(height: 12),
          smallButton(
            label: 'Invite',
            icon: Icons.person_add_alt_1,
            filled: false,
            onPressed: onInvite,
          ),
        ],
      ],
    );
  }
}