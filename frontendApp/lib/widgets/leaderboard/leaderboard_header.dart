import 'package:flutter/material.dart';

class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leaderboard',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "See who's putting in the miles.",
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}