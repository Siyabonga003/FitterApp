import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final String km;
  final int activities;
  final int trend;
  final bool isCurrentUser;
  final String? imageUrl;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.km,
    required this.activities,
    required this.trend,
    this.isCurrentUser = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.primaryNeon.withOpacity(.08)
            : (isDark ? AppTheme.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(22),
        border: isCurrentUser
            ? Border.all(
          color: AppTheme.primaryNeon,
          width: 1.5,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),

      child: Row(
        children: [

          // Rank

          SizedBox(
            width: 34,
            child: Text(
              "#$rank",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar

          Hero(
            tag: "leader_$rank",
            child: CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryNeon,

              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : null,

              child: imageUrl == null
                  ? Text(
                name[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
                  : null,
            ),
          ),

          const SizedBox(width: 16),

          // Name + subtitle

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    if (rank <= 3)
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue,
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [

                    Icon(
                      Icons.directions_run,
                      size: 15,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      "$activities Activities",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Distance + Trend

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              RichText(
                text: TextSpan(
                  children: [

                    TextSpan(
                      text: km,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),

                    TextSpan(
                      text: " km",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  if (trend > 0)
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.green,
                      size: 16,
                    ),

                  if (trend < 0)
                    const Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.red,
                      size: 16,
                    ),

                  if (trend == 0)
                    const Icon(
                      Icons.remove,
                      color: Colors.grey,
                      size: 16,
                    ),

                  const SizedBox(width: 3),

                  Text(
                    trend == 0
                        ? "--"
                        : trend.abs().toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: trend > 0
                          ? Colors.green
                          : trend < 0
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}