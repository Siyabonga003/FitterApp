import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('GROUPS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Create Group Action Trigger Button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_rounded, color: AppTheme.primaryOrange),
                label: const Text(
                  'Create Group',
                  style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  // Provisioning flow placeholder
                },
              ),
            ),
            const SizedBox(height: 20),

            // Groups Vertical Scrolling Feed Layout List
            Expanded(
              child: ListView(
                children: [
                  const GroupCard(
                    groupName: 'Family Runners',
                    memberCount: 14,
                    progressLabel: 'Goal → 200km this month',
                    progressValue: 0.68,
                    percentageText: '68%',
                  ),
                  const SizedBox(height: 16),
                  const GroupCard(
                    groupName: 'Campus Running Club',
                    memberCount: 43,
                    progressLabel: 'Goal → 500km this month',
                    progressValue: 0.32,
                    percentageText: '32%',
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

// 🛠️ REUSABLE UI CARD COMPONENT: GroupCard Widget
class GroupCard extends StatelessWidget {
  final String groupName;
  final int memberCount;
  final String progressLabel;
  final double progressValue;
  final String percentageText;

  const GroupCard({
    required this.groupName,
    required this.memberCount,
    required this.progressLabel,
    required this.progressValue,
    required this.percentageText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Content Meta Title info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    groupName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textWhite, fontSize: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), // Fixed custom opacity error
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$memberCount Members',
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Challenge Progress Label Text info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(progressLabel, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                Text(percentageText, style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            // High Performance custom linear indicator block bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}