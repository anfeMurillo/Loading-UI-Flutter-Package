import 'dart:math' as math;
import 'package:flutter/material.dart';

class RingArcSegment {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  const RingArcSegment({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });
}

class RingArcPainter extends CustomPainter {
  final double strokeWidth;
  final Color? backgroundColor;
  final List<RingArcSegment> segments;
  final StrokeCap strokeCap;

  const RingArcPainter({
    required this.strokeWidth,
    required this.segments,
    this.backgroundColor,
    this.strokeCap = StrokeCap.butt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (backgroundColor != null) {
      final bg = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, bg);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    for (final s in segments) {
      paint.color = s.color;
      canvas.drawArc(rect, s.startAngle, s.sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RingArcPainter old) =>
      old.strokeWidth != strokeWidth ||
      old.backgroundColor != backgroundColor ||
      old.strokeCap != strokeCap ||
      old.segments != segments;
}
