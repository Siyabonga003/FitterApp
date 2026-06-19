import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class ActivityCard extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String activityTitle;
  final String distance;
  final String duration;
  final String pace;

  const ActivityCard({
    required this.username,
    required this.timeAgo,
    required this.activityTitle,
    required this.distance,
    required this.duration,
    required this.pace,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryNeon.withOpacity(0.1),
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'F',
                    style: const TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isDark ? AppTheme.textWhite : AppTheme.textDark)),
                    Text(timeAgo, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(activityTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isDark ? AppTheme.textWhite : AppTheme.textDark)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric(context, 'Distance', distance),
                _buildMetric(context, 'Time', duration),
                _buildMetric(context, 'Pace', pace),
              ],
            ),
            const SizedBox(height: 16),
            ActivityMapSnapshot(isDark: isDark),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(Icons.favorite_border_rounded, '25', context),
                _buildActionButton(Icons.chat_bubble_outline_rounded, '8', context),
                _buildActionButton(Icons.workspace_premium_outlined, 'Cheer', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textLight),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight)),
      ],
    );
  }
}

class ActivityMapSnapshot extends StatelessWidget {
  final bool isDark;
  const ActivityMapSnapshot({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090A0C) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.04 : 0.15,
              child: GridPaper(color: isDark ? Colors.white : Colors.black, divisions: 2, subdivisions: 1, interval: 40),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomPaint(painter: RouteLinePainter(routeColor: AppTheme.primaryNeon, isDark: isDark)),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.primaryNeon),
                  const SizedBox(width: 4),
                  Text('Downtown Loop Route', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RouteLinePainter extends CustomPainter {
  final Color routeColor;
  final bool isDark;
  RouteLinePainter({required this.routeColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()..color = routeColor..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    if (isDark) {
      canvas.drawPath(_createMockPath(size), Paint()..color = routeColor.withOpacity(0.25)..style = PaintingStyle.stroke..strokeWidth = 8.0..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
    canvas.drawPath(_createMockPath(size), pathPaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 5.5, Paint()..color = routeColor);
  }

  Path _createMockPath(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.75);
    path.cubicTo(size.width * 0.35, size.height * 0.90, size.width * 0.40, size.height * 0.30, size.width * 0.60, size.height * 0.45);
    path.lineTo(size.width * 0.85, size.height * 0.25);
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}