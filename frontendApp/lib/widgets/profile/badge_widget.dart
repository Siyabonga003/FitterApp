import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class BadgeWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final bool isNew;

  const BadgeWidget({
    required this.emoji,
    required this.title,
    this.isNew = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? AppTheme.primaryOrange.withOpacity(0.6) : Colors.white10,
          width: isNew ? 1.5 : 1,
        ),
        boxShadow: isNew
            ? [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 11, fontWeight: FontWeight.w500)),
          if (isNew) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('NEW',
                  style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
          ],
        ],
      ),
    );
  }
}