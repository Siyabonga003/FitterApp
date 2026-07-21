import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/providers/runner_location_provider.dart';
import 'package:frontend_app/theme/app_theme.dart';

class LiveRunnerCard extends ConsumerWidget {
  final String userId;
  final String name;
  final String status;
  final String metric;
  final String initial;

  const LiveRunnerCard({
    required this.userId,
    required this.name,
    required this.status,
    required this.metric,
    required this.initial,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12, bottom: 20, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                child: Text(initial,
                    style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status,
                  style: const TextStyle(
                      color: AppTheme.textLight, fontSize: 11)),
              const SizedBox(height: 2),
              Text(metric,
                  style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  await ref
                      .read(runnerLocationProvider.notifier)
                      .sendCheer(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Cheered $name! 👏'),
                      backgroundColor: AppTheme.primaryOrange,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primaryOrange.withOpacity(0.4),
                        width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.electric_bolt_rounded,
                          color: AppTheme.primaryOrange, size: 12),
                      SizedBox(width: 3),
                      Text('Cheer',
                          style: TextStyle(
                              color: AppTheme.primaryOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}