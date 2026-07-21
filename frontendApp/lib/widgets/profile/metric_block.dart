import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class MetricBlock extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const MetricBlock({
    required this.title,
    required this.value,
    required this.unit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.primaryOrange, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}