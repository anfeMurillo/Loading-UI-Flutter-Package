import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A reusable [CustomPainter] for drawing circular arcs.
/// 
/// Used by many ring-based loaders like 'ring', 'arc', 'dual-arc', etc.
class ArcPainter extends CustomPainter {
  /// The color of the arc.
  final Color color;

  /// The thickness of the arc stroke.
  final double strokeWidth;

  /// The angle at which the arc starts (in radians).
  final double startAngle;

  /// The length of the arc (in radians).
  final double sweepAngle;

  /// The style of the stroke ends.
  final StrokeCap strokeCap;

  /// Whether to use a dash pattern (optional enhancement).
  final List<double>? dashArray;

  ArcPainter({
    required this.color,
    required this.strokeWidth,
    this.startAngle = 0.0,
    this.sweepAngle = math.pi * 1.5, // 270 degrees
    this.strokeCap = StrokeCap.round,
    this.dashArray,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    if (dashArray == null) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    } else {
      // Basic dash implementation could go here if needed, 
      // but for Phase 0 we'll keep it simple.
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.dashArray != dashArray;
  }
}
