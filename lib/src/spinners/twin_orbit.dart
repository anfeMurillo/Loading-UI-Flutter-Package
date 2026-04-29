import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Two dots orbiting a common center in opposite directions.
///
/// Each dot traces a circular path; the second runs 180° phase-shifted so
/// they cross at the midpoints, creating a figure-eight orbit illusion.
/// Respects [MediaQueryData.disableAnimations].
class TwinOrbitLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const TwinOrbitLoader({
    super.key,
    this.size = 12.0,
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

  Widget _dot(Color c) => Container(
    width: widget.size,
    height: widget.size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  Offset _orbitOffset(double t) {
    final eased = Curves.easeInOut.transform(t);
    final angle = eased * 2 * math.pi;
    final r = widget.size * 1.55;
    return Offset(math.cos(angle) * r, math.sin(angle) * r);
  }

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t1 = _ctrl.value;
          final t2 = phaseOf(_ctrl.value, 0.5);
          final o1 = _orbitOffset(t1);
          final o2 = _orbitOffset(t2);
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _dot(c),
                Positioned(left: o1.dx, top: o1.dy, child: _dot(c)),
                Positioned(left: o2.dx, top: o2.dy, child: _dot(c)),
              ],
            ),
          );
        },
      ),
    );
  }
}
