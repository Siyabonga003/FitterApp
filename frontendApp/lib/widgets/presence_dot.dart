import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class PresenceDot extends StatelessWidget {
  final String initial;
  final bool isActive;
  final String activityEmoji;

  const PresenceDot({
    required this.initial,
    required this.isActive,
    required this.activityEmoji,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor =
    isActive ? AppTheme.primaryOrange : const Color(0xFF4A5568);
    final glowColor =
    isActive ? AppTheme.primaryOrange : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isActive)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glowColor.withOpacity(0.15),
                  border: Border.all(
                    color: glowColor.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
              ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: isActive ? 2 : 0,
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            if (activityEmoji.isNotEmpty)
              Positioned(
                top: isActive ? 2 : 0,
                right: isActive ? 2 : 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: Center(
                    child: Text(activityEmoji,
                        style: const TextStyle(fontSize: 8)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}