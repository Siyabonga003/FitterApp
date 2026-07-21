import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class CurrentUserCard extends StatelessWidget {
  const CurrentUserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 95,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xff1F2937),
            const Color(0xff111827),
          ]
              : [
            AppTheme.primaryNeon.withOpacity(.95),
            AppTheme.primaryNeon.withOpacity(.75),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeon.withOpacity(.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [

            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(.2),
              child: const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/300?img=12",
                ),
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    "You",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "#28 • 84.6 km",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Only 6 km behind #27",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}