import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../theme/app_theme.dart';

class GroupHeaderSection extends StatelessWidget {
  final GroupDetailModel detail;

  const GroupHeaderSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.name,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          detail.description,
          style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
        ),
        if (detail.hasGoal) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                detail.progressLabel,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
              Text(
                detail.percentageText,
                style: const TextStyle(
                  color: AppTheme.primaryNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: detail.progressValue,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
            ),
          ),
        ],
      ],
    );
  }
}