import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/painters/ring_arc_painter.dart';

/// Two concentric rings: a faded outer ring and an inner 90° accent arc.
///
/// Both rotate together as a single unit.
/// Respects [MediaQueryData.disableAnimations].
class ConcentricRingLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const ConcentricRingLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<ConcentricRingLoader> createState() => _ConcentricRingLoaderState();
}

class _ConcentricRingLoaderState extends State<ConcentricRingLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(ConcentricRingLoader oldWidget) {
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
    // CSS uses a fixed `border-2` (2px) regardless of element size, which
    // is what creates the visible gap between the inner and outer rings at
    // larger sizes. Keep the default fixed; pass [strokeWidth] to override.
    final stroke = widget.strokeWidth ?? 2.0;
    final faded = c.withValues(alpha: c.a * 0.25);
    final inner = widget.size * 0.83333;
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _ctrl,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: RingArcPainter(
                  strokeWidth: stroke,
                  segments: const [],
                  backgroundColor: faded,
                ),
              ),
            ),
            Positioned(
              left: (widget.size - inner) / 2,
              top: (widget.size - inner) / 2,
              width: inner,
              height: inner,
              child: CustomPaint(
                painter: RingArcPainter(
                  strokeWidth: stroke,
                  segments: [
                    RingArcSegment(
                      startAngle: math.pi / 4,
                      sweepAngle: math.pi / 2,
                      color: c,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
