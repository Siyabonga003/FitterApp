import 'package:flutter/material.dart';
import 'package:frontend_app/models/leaderboard_user.dart';
import 'package:frontend_app/theme/app_theme.dart';

class CurrentUserCard extends StatelessWidget {
  final LeaderboardUser user;
  final double kmBehindNext;

  const CurrentUserCard({
    super.key,
    required this.user,
    required this.kmBehindNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryNeon, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'YOU',
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${user.rank}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${user.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: AppTheme.primaryNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: user.goalProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(user.goalProgress * 100).toInt()}% Goal',
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Only ${kmBehindNext.toStringAsFixed(1)} km behind #${user.rank - 1}',
              style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
            ),
          )
        ],
      ),
    );
  }
}