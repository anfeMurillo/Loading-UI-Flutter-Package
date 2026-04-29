import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/painters/ring_arc_painter.dart';

/// A single growing-arc spinner.
///
/// Draws one arc whose sweep angle oscillates as it rotates, creating a
/// winding/unwinding effect. Respects [MediaQueryData.disableAnimations].
class ArcLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const ArcLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<ArcLoader> createState() => _ArcLoaderState();
}

class _ArcLoaderState extends State<ArcLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(ArcLoader oldWidget) {
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
    final stroke = widget.strokeWidth ?? 5.0 * (widget.size / 24);
    final faded = c.withValues(alpha: c.a * 0.1);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _ctrl,
        child: CustomPaint(
          painter: RingArcPainter(
            strokeWidth: stroke,
            backgroundColor: faded,
            segments: [
              RingArcSegment(
                startAngle: -3 * math.pi / 4,
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
