import 'dart:ui' as ui;
import 'package:flutter/material.dart';


class HeadingConePainter extends CustomPainter {
  final Color color;
  const HeadingConePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tipLength = size.height * 0.48;
    final halfWidth = size.width * 0.30;

    final path = ui.Path()
      ..moveTo(center.dx, center.dy - tipLength)
      ..lineTo(center.dx - halfWidth, center.dy)
      ..arcToPoint(
        Offset(center.dx + halfWidth, center.dy),
        radius: Radius.circular(halfWidth),
        clockwise: false,
      )
      ..close();

    final gradient = ui.Gradient.linear(
      Offset(center.dx, center.dy - tipLength),
      Offset(center.dx, center.dy),
      [color.withOpacity(0.35), color.withOpacity(0.0)],
    );

    final paint = Paint()..shader = gradient;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeadingConePainter old) => old.color != color;
}