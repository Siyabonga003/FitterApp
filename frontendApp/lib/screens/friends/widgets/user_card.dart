import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class UserCard extends StatelessWidget {
  final String initial;
  final String displayName;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onProfileTap;

  const UserCard({
    super.key,
    required this.initial,
    required this.displayName,
    required this.subtitle,
    required this.trailing,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(18),
            splashColor: AppTheme.primaryOrange.withOpacity(0.2),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}