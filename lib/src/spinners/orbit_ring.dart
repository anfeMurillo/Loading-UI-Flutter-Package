import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/painters/ring_arc_painter.dart';

/// A faded inner ring with a larger outer 90° accent arc.
///
/// Both rings rotate together as a single unit.
/// Respects [MediaQueryData.disableAnimations].
class OrbitRingLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const OrbitRingLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<OrbitRingLoader> createState() => _OrbitRingLoaderState();
}

class _OrbitRingLoaderState extends State<OrbitRingLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(OrbitRingLoader oldWidget) {
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
    // Fixed 2px stroke matches CSS `border-2`; preserves the visible gap
    // between the inner faded ring and the outer accent ring at larger sizes.
    final stroke = widget.strokeWidth ?? 2.0;
    final faded = c.withValues(alpha: c.a * 0.25);
    final outer = widget.size * 1.16667;
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _ctrl,
        child: Stack(
          clipBehavior: Clip.none,
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
              left: (widget.size - outer) / 2,
              top: (widget.size - outer) / 2,
              width: outer,
              height: outer,
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
