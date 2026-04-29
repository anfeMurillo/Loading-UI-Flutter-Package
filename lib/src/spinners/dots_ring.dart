import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// A ring of dots that fade in sequence.
///
/// Multiple small dots are placed equidistant around a circle. Each dot
/// pulses opacity with a staggered phase offset, creating a running-light
/// effect around the ring. Respects [MediaQueryData.disableAnimations].
class DotsRingLoader extends StatefulWidget {
  final double size;
  final int dots;
  final double dotScale;
  final double radiusScale;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const DotsRingLoader({
    super.key,
    this.size = 32.0,
    this.dots = 8,
    this.dotScale = 0.16,
    this.radiusScale = 0.34,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.semanticsLabel,
  });

  @override
  State<DotsRingLoader> createState() => _DotsRingLoaderState();
}

class _DotsRingLoaderState extends State<DotsRingLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(DotsRingLoader oldWidget) {
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
    final dotCount = math.max(4, widget.dots);
    final safeDotScale = widget.dotScale.clamp(0.2, 0.4);
    final safeRadiusScale = widget.radiusScale.clamp(
      0.0,
      0.5 - safeDotScale / 2,
    );
    final dotSize = widget.size * safeDotScale;
    final radius = widget.size * safeRadiusScale;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => Stack(
          children: List.generate(dotCount, (i) {
            final angle = (i / dotCount) * math.pi * 2;
            final x = math.sin(angle) * radius;
            final y = -math.cos(angle) * radius;
            final t = phaseOf(_ctrl.value, i / dotCount);
            final scale = lerpStops(
              t,
              const [0.0, 0.125, 0.25, 0.5, 1.0],
              const [0.65, 1.0, 0.85, 0.7, 0.65],
            );
            final opacity = lerpStops(
              t,
              const [0.0, 0.125, 0.25, 0.5, 1.0],
              const [0.25, 1.0, 0.75, 0.35, 0.25],
            );
            return Positioned(
              left: widget.size / 2 + x - dotSize / 2,
              top: widget.size / 2 + y - dotSize / 2,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
