import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LeaderboardEmptyState extends StatelessWidget {
  const LeaderboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏃', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'No rankings yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Start your first run to kickstart the board!',
            style: TextStyle(color: AppTheme.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}