import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/painters/ring_arc_painter.dart';

/// Two opposing 90° arcs (top and bottom) rotating together.
///
/// Renders top and bottom arcs of a ring; both rotate as a single unit.
/// Respects [MediaQueryData.disableAnimations].
class DualArcLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const DualArcLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<DualArcLoader> createState() => _DualArcLoaderState();
}

class _DualArcLoaderState extends State<DualArcLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(DualArcLoader oldWidget) {
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
    // Fixed 5px stroke matches CSS `border-[5px]`; the original border width
    // does not scale with element size.
    final stroke = widget.strokeWidth ?? 5.0;
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
                startAngle: -3 * math.pi / 4,
                sweepAngle: math.pi / 2,
                color: c,
              ),
              RingArcSegment(
                startAngle: math.pi / 4,
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
