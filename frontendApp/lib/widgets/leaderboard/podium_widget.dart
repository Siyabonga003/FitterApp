import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class PodiumWidget extends StatelessWidget {
  const PodiumWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          Expanded(
            child: _PodiumCard(
              position: 2,
              name: "Alice",
              km: "344",
              activities: 10,
              color: Color(0xffCFCFCF),
              height: 145,
              image:
              "https://i.pravatar.cc/300?img=47",
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _PodiumCard(
              position: 1,
              name: "John Smith",
              km: "368",
              activities: 12,
              color: Color(0xffF5C542),
              height: 165,
              champion: true,
              image:
              "https://i.pravatar.cc/300?img=12",
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _PodiumCard(
              position: 3,
              name: "Brian",
              km: "319",
              activities: 9,
              color: Color(0xffC78658),
              height: 145,
              image:
              "https://i.pravatar.cc/300?img=14",
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final int position;
  final String name;
  final String km;
  final int activities;
  final Color color;
  final double height;
  final bool champion;
  final String image;

  const _PodiumCard({
    required this.position,
    required this.name,
    required this.km,
    required this.activities,
    required this.color,
    required this.height,
    required this.image,
    this.champion = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [

          Positioned(
            top: 35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 55, 12, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkCard
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),

              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: champion ? 17 : 15,
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  RichText(
                    text: TextSpan(
                      children: [

                        TextSpan(
                          text: km,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: champion ? 40 : 28,
                          ),
                        ),

                        TextSpan(
                          text: " km",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Icon(
                        Icons.directions_run,
                        size: 16,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        "$activities Activities",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          CircleAvatar(
            radius: champion ? 36 : 30,
            backgroundColor: color,
            child: CircleAvatar(
              radius: champion ? 33 : 27,
              backgroundImage: NetworkImage(image),
            ),
          ),

          Positioned(
            top: -10,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: color,
              child: Text(
                "$position",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (champion)
            const Positioned(
              top: -38,
              child: Icon(
                Icons.workspace_premium,
                size: 34,
                color: Color(0xffF5C542),
              ),
            ),
        ],
      ),
    );
  }
}