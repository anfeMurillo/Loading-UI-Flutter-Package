import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// A spiral of fading dots.
///
/// Dots are arranged along a spiral path, each fading in/out with a phase
/// offset that creates a cascading, rotating wave effect.
/// Respects [MediaQueryData.disableAnimations].
class SpiralLoader extends StatefulWidget {
  final double size;
  final int dots;
  final double radiusFraction;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const SpiralLoader({
    super.key,
    this.size = 32.0,
    this.dots = 8,
    this.radiusFraction = 0.3125,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.semanticsLabel,
  });

  @override
  State<SpiralLoader> createState() => _SpiralLoaderState();
}

class _SpiralLoaderState extends State<SpiralLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(SpiralLoader oldWidget) {
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
    final radius = widget.size * widget.radiusFraction;
    final dotSize = widget.size * 1.5 / widget.dots;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => Stack(
          children: List.generate(widget.dots, (i) {
            final angle = (i / widget.dots) * 2 * math.pi;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            final t = phaseOf(_ctrl.value, i / widget.dots);
            final scale = lerpStops(
              t,
              const [0.0, 0.5, 1.0],
              const [0.0, 1.0, 0.0],
              curve: Curves.easeInOut,
            );
            final opacity = lerpStops(
              t,
              const [0.0, 0.5, 1.0],
              const [0.0, 1.0, 0.0],
              curve: Curves.easeInOut,
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
