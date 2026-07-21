import 'package:flutter/material.dart';
import '../../models/leaderboard_user.dart';
import '../../theme/app_theme.dart';
import 'avatar_with_progress.dart';
import 'leaderboard_rank_change.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardUser user;
  final VoidCallback onTap;

  const LeaderboardTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '#${user.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppTheme.textDark.withOpacity(0.7),
                    ),
                  ),
                ),
                AvatarWithProgress(
                  imageUrl: user.profileImage,
                  progress: user.goalProgress,
                  size: 42,
                  isVerified: user.isVerified,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '🏃 ${user.activitiesCount} Runs',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🔥 ${user.streakDays}d',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: user.distanceKm.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                          const TextSpan(
                            text: ' km',
                            style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    LeaderboardRankChange(trend: user.trend, amount: user.trendAmount),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}