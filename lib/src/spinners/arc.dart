import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/painters/ring_arc_painter.dart';

/// A faded ring with a single 90° accent arc that rotates.
///
/// Draws a full ring at 10% opacity with a top 90° arc at full opacity,
/// rotating continuously. Respects [MediaQueryData.disableAnimations].
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
    // Fixed 5px stroke matches CSS `border-[5px]`; the original border width
    // does not scale with element size.
    final stroke = widget.strokeWidth ?? 5.0;
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
