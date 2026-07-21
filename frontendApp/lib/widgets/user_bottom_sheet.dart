import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/runner_location.dart';
import 'package:frontend_app/providers/runner_location_provider.dart';
import 'package:frontend_app/theme/app_theme.dart';

class UserBottomSheet extends ConsumerWidget {
  final RunnerLocation loc;

  const UserBottomSheet({required this.loc, super.key});

  String _activityEmoji(int? typeId) {
    switch (typeId) {
      case 1: return '🏃';
      case 2: return '🚴';
      case 3: return '🚶';
      default: return '🏃';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                child: Text(
                  loc.displayName.isNotEmpty
                      ? loc.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.displayName,
                      style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    loc.sharingLive
                        ? '${_activityEmoji(loc.activityTypeId)} Currently running'
                        : '📍 Online',
                    style: const TextStyle(
                        color: AppTheme.textLight, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          if (loc.sharingLive) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statChip('📏', loc.formattedDistance),
                _statChip('⚡', loc.formattedPace),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.electric_bolt_rounded,
                  color: Colors.white, size: 18),
              label: const Text('Send Cheer',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(runnerLocationProvider.notifier)
                    .sendCheer(loc.userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Cheered ${loc.displayName}! 👏'),
                    backgroundColor: AppTheme.primaryOrange,
                  ));
                }
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}