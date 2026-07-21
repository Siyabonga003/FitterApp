import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/models/activity_model.dart';
import 'package:frontend_app/utils/image_url.dart';

class ActivityCard extends StatelessWidget {
  final String username;
  final String? profilePicUrl;
  final String timeAgo;
  final String activityTitle;
  final String distance;
  final String duration;
  final String pace;
  final List<RoutePoint> routePoints;

  const ActivityCard({
    required this.username,
    this.profilePicUrl,
    required this.timeAgo,
    required this.activityTitle,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.routePoints,
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
                  backgroundImage: resolveImageUrl(profilePicUrl) != null
                      ? NetworkImage(resolveImageUrl(profilePicUrl)!)
                      : null,
                  child: (profilePicUrl == null || profilePicUrl!.isEmpty)
                      ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'F',
                    style: const TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold),
                  )
                      : null,
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
            ActivityMapSnapshot(isDark: isDark, routePoints: routePoints),
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
  final List<RoutePoint> routePoints;

  const ActivityMapSnapshot({required this.isDark, required this.routePoints, super.key});

  @override
  Widget build(BuildContext context) {
    final hasRoute = routePoints.length >= 2;

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
          if (hasRoute)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CustomPaint(
                  painter: RouteLinePainter(routeColor: AppTheme.primaryNeon, isDark: isDark, points: routePoints),
                ),
              ),
            )
          else
            Center(
              child: Text(
                'No route recorded',
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
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
  final List<RoutePoint> points;

  RouteLinePainter({required this.routeColor, required this.isDark, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = _buildPath(size);

    final pathPaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isDark) {
      canvas.drawPath(
        path,
        Paint()
          ..color = routeColor.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    canvas.drawPath(path, pathPaint);

    final offsets = _pointsToOffsets(size);
    canvas.drawCircle(offsets.first, 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(offsets.last, 5.5, Paint()..color = routeColor);
  }

  Path _buildPath(Size size) {
    final offsets = _pointsToOffsets(size);
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  List<Offset> _pointsToOffsets(Size size) {
    final lats = points.map((p) => p.lat).toList();
    final lngs = points.map((p) => p.lng).toList();

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    final latRange = (maxLat - minLat).abs() < 1e-9 ? 1.0 : (maxLat - minLat);
    final lngRange = (maxLng - minLng).abs() < 1e-9 ? 1.0 : (maxLng - minLng);

    return points.map((p) {
      final normX = (p.lng - minLng) / lngRange;
      final normY = 1.0 - ((p.lat - minLat) / latRange);
      return Offset(normX * size.width, normY * size.height);
    }).toList();
  }

  @override
  bool shouldRepaint(covariant RouteLinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.isDark != isDark;
  }
}