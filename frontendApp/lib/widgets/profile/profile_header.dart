import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String initial;
  final String? profilePicUrl;
  final int totalSessions;
  final VoidCallback onTapAvatar;

  const ProfileHeader({
    required this.displayName,
    required this.initial,
    required this.totalSessions,
    required this.onTapAvatar,
    this.profilePicUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTapAvatar,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                backgroundImage: (profilePicUrl != null && profilePicUrl!.isNotEmpty)
                    ? NetworkImage(profilePicUrl!)
                    : null,
                child: (profilePicUrl == null || profilePicUrl!.isEmpty)
                    ? Text(
                  initial,
                  style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.darkBg, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.isEmpty ? 'Runner' : displayName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 26, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalSessions runs completed',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}