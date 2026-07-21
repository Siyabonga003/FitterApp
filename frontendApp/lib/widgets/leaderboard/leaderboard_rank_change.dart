import 'package:flutter/material.dart';
import '../../models/leaderboard_user.dart';
import '../../theme/app_theme.dart';

class LeaderboardRankChange extends StatelessWidget {
  final RankTrend trend;
  final int amount;

  const LeaderboardRankChange({
    super.key,
    required this.trend,
    this.amount = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (trend) {
      case RankTrend.up:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_drop_up_rounded, color: AppTheme.success, size: 20),
            Text(
              '$amount',
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case RankTrend.down:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.danger, size: 20),
            Text(
              '$amount',
              style: const TextStyle(
                color: AppTheme.danger,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case RankTrend.isNew:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryNeon.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'NEW',
            style: TextStyle(
              color: AppTheme.primaryNeon,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case RankTrend.unchanged:
      default:
        return Text(
          '—',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }
}