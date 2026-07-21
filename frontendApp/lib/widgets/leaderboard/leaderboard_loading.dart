import 'package:flutter/material.dart';

class LeaderboardLoading extends StatelessWidget {
  const LeaderboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white10 : Colors.black12;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: baseColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 120, height: 12, color: baseColor),
                  const SizedBox(height: 6),
                  Container(width: 80, height: 8, color: baseColor),
                ],
              ),
              const Spacer(),
              Container(width: 40, height: 16, color: baseColor),
            ],
          ),
        ),
      ),
    );
  }
}