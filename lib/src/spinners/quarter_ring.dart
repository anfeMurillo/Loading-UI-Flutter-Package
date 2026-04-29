import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/painters/ring_arc_painter.dart';

/// A quarter-ring (quarter-circle arc) spinner.
///
/// Draws a 90° arc that rotates continuously. Compact and minimal.
/// Respects [MediaQueryData.disableAnimations].
class QuarterRingLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const QuarterRingLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<QuarterRingLoader> createState() => _QuarterRingLoaderState();
}

class _QuarterRingLoaderState extends State<QuarterRingLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(QuarterRingLoader oldWidget) {
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
    final c = resolveColor(context, widget.color);
    final stroke = widget.strokeWidth ?? 3.0 * (widget.size / 24);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _ctrl,
        child: CustomPaint(
          painter: RingArcPainter(
            strokeWidth: stroke,
            segments: [
              RingArcSegment(
                startAngle: -math.pi / 2,
                sweepAngle: math.pi / 2,
                color: c,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
