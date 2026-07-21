import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class WeeklyActivityCard extends StatelessWidget {
  final List<int> activeDaysThisWeek;

  const WeeklyActivityCard({required this.activeDaysThisWeek, super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: Colors.white)),
                Text(
                  '${activeDaysThisWeek.length} of 7 days',
                  style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DayIndicator(label: 'M', isCompleted: activeDaysThisWeek.contains(1)),
                _DayIndicator(label: 'T', isCompleted: activeDaysThisWeek.contains(2)),
                _DayIndicator(label: 'W', isCompleted: activeDaysThisWeek.contains(3)),
                _DayIndicator(label: 'T', isCompleted: activeDaysThisWeek.contains(4)),
                _DayIndicator(label: 'F', isCompleted: activeDaysThisWeek.contains(5)),
                _DayIndicator(label: 'S', isCompleted: activeDaysThisWeek.contains(6)),
                _DayIndicator(label: 'S', isCompleted: activeDaysThisWeek.contains(7)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String label;
  final bool isCompleted;

  const _DayIndicator({required this.label, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.primaryOrange : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: isCompleted ? Colors.transparent : Colors.white10),
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.add_rounded,
              size: 16,
              color: isCompleted ? Colors.white : Colors.white30,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: isCompleted ? AppTheme.textWhite : AppTheme.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}