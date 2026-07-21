import 'package:flutter/material.dart';
import '../../models/leaderboard_user.dart';
import '../../theme/app_theme.dart';
import 'avatar_with_progress.dart';

class TopAthletesWidget extends StatelessWidget {
  final List<LeaderboardUser> topThree;
  final Function(LeaderboardUser) onUserTap;

  const TopAthletesWidget({
    super.key,
    required this.topThree,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final first = topThree.length > 0 ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Top Athletes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (first != null) _buildFirstPlaceCard(context, first),
          const SizedBox(height: 8),
          Row(
            children: [
              if (second != null) Expanded(child: _buildSecondaryCard(context, second, 2)),
              if (second != null && third != null) const SizedBox(width: 8),
              if (third != null) Expanded(child: _buildSecondaryCard(context, third, 3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFirstPlaceCard(BuildContext context, LeaderboardUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onUserTap(user),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNeon.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            AvatarWithProgress(
              imageUrl: user.profileImage,
              progress: user.goalProgress,
              size: 52,
              isVerified: user.isVerified,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 4),
                      const Text('🥇', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('🏃 ${user.activitiesCount} Runs', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                      const SizedBox(width: 8),
                      Text('🔥 ${user.streakDays}d Streak', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.distanceKm.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNeon,
                  ),
                ),
                const Text('km', style: TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryCard(BuildContext context, LeaderboardUser user, int rank) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badge = rank == 2 ? '🥈' : '🥉';

    return GestureDetector(
      onTap: () => onUserTap(user),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(badge, style: const TextStyle(fontSize: 14)),
                AvatarWithProgress(
                  imageUrl: user.profileImage,
                  progress: user.goalProgress,
                  size: 40,
                  isVerified: user.isVerified,
                ),
                const SizedBox(width: 14), // Balances the top row
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${user.distanceKm.toStringAsFixed(1)} ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const TextSpan(
                    text: 'km',
                    style: TextStyle(fontSize: 10, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}