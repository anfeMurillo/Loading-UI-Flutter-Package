import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// The classic iOS-style activity indicator.
///
/// 12 fading radial lines that rotate with staggered opacity, reproducing
/// the familiar platform-native spinner look in pure Flutter.
/// Respects [MediaQueryData.disableAnimations].
class ClassicLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const ClassicLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.semanticsLabel,
  });

  @override
  State<ClassicLoader> createState() => _ClassicLoaderState();
}

class _ClassicLoaderState extends State<ClassicLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(ClassicLoader oldWidget) {
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
    final s = widget.size;
    final barW = s * 0.24;
    final barH = s * 0.08;
    final radius = s * 0.35;
    const count = 12;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: s,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => Stack(
          children: List.generate(count, (i) {
            final t = phaseOf(_ctrl.value, i / count);
            final opacity = lerpStops(t, const [0.0, 1.0], const [1.0, 0.15]);
            final angle = i * (math.pi / 6);
            final dx = math.cos(angle) * radius;
            final dy = math.sin(angle) * radius;
            return Positioned(
              left: s / 2 - barW / 2 + dx,
              top: s / 2 - barH / 2 + dy,
              child: Transform.rotate(
                angle: angle,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: barW,
                    height: barH,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(barH / 2),
                    ),
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
