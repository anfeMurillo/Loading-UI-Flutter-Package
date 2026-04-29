import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Two dots orbiting a common center, 180° out of phase.
///
/// Both dots orbit in the same direction; the second is delayed by half
/// the duration so they appear on opposite sides of the center.
/// Respects [MediaQueryData.disableAnimations].
class TwinOrbitLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const TwinOrbitLoader({
    super.key,
    this.size = 48.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.semanticsLabel,
  });

  @override
  State<TwinOrbitLoader> createState() => _TwinOrbitLoaderState();
}

class _TwinOrbitLoaderState extends State<TwinOrbitLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TwinOrbitLoader oldWidget) {
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

  Widget _dot(Color c, double dotSize) => Container(
    width: dotSize,
    height: dotSize,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  Offset _orbitOffset(double t, double r) {
    final eased = Curves.easeInOut.transform(t);
    final angle = eased * 2 * math.pi;
    return Offset(math.cos(angle) * r, math.sin(angle) * r);
  }

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    // [size] is the overall bounding box. Original CSS sets dot = container,
    // orbit radius = 1.55 × dot, giving bounding = 2 × (1.55 + 0.5) × dot
    // = 4.1 × dot. So dotSize = size / 4.1.
    final dotSize = widget.size / 4.1;
    final orbitR = dotSize * 1.55;
    final centerLeft = widget.size / 2 - dotSize / 2;
    final centerTop = widget.size / 2 - dotSize / 2;
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t1 = _ctrl.value;
          final t2 = phaseOf(_ctrl.value, 0.5);
          final o1 = _orbitOffset(t1, orbitR);
          final o2 = _orbitOffset(t2, orbitR);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: centerLeft,
                top: centerTop,
                child: _dot(c, dotSize),
              ),
              Positioned(
                left: centerLeft + o1.dx,
                top: centerTop + o1.dy,
                child: _dot(c, dotSize),
              ),
              Positioned(
                left: centerLeft + o2.dx,
                top: centerTop + o2.dy,
                child: _dot(c, dotSize),
              ),
            ],
          );
        },
      ),
    );
  }
}
