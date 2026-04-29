import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A radial spokes (wheel) spinner.
///
/// Draws 8 evenly-spaced line segments at full opacity; the whole figure
/// rotates continuously. Respects [MediaQueryData.disableAnimations].
class SpokesLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const SpokesLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<SpokesLoader> createState() => _SpokesLoaderState();
}

class _SpokesLoaderState extends State<SpokesLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(SpokesLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _ctrl.duration = widget.duration;
      if (_ctrl.isAnimating) _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stroke = widget.strokeWidth ?? widget.size / 12;
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _ctrl,
        child: CustomPaint(
          painter: _SpokesPainter(
            color: resolveColor(context, widget.color),
            strokeWidth: stroke,
          ),
        ),
      ),
    );
  }
}

class _SpokesPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _SpokesPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = math.min(size.width, size.height) / 2;
    final innerR = half * (6 / 12);
    final outerR = half * (10 / 12);

    for (var i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      canvas.drawLine(
        Offset(cx + dx * innerR, cy + dy * innerR),
        Offset(cx + dx * outerR, cy + dy * outerR),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpokesPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
