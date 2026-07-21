import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AvatarWithProgress extends StatelessWidget {
  final String? imageUrl;
  final double progress;
  final double size;
  final bool isVerified;

  const AvatarWithProgress({
    super.key,
    this.imageUrl,
    required this.progress,
    this.size = 48,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            backgroundColor: AppTheme.primaryNeon.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
          ),
        ),
        CircleAvatar(
          radius: (size - 6) / 2,
          backgroundColor: Theme.of(context).cardColor,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Icon(Icons.person, size: size * 0.5, color: Colors.grey)
              : null,
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.primaryNeon,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }
}