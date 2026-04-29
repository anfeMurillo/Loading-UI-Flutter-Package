import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Dots that bounce vertically in a staggered wave.
///
/// Each dot translates upward then returns with a sinusoidal-like eased
/// motion, phase-shifted relative to its neighbours. The result is a
/// cascading bounce wave. Respects [MediaQueryData.disableAnimations].
class BouncingDotsLoader extends StatefulWidget {
  final double size;
  final int dots;
  final Color? color;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const BouncingDotsLoader({
    super.key,
    this.size = 32.0,
    this.dots = 3,
    this.color,
    this.duration = const Duration(milliseconds: 1400),
    this.delay = const Duration(milliseconds: 200),
    this.semanticsLabel,
  });

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(BouncingDotsLoader oldWidget) {
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
    final delayFraction =
        widget.delay.inMicroseconds / widget.duration.inMicroseconds;
    final gap = widget.size * 0.12 / (widget.dots + 1);
    final dotSize = (widget.size - gap * (widget.dots - 1)) / widget.dots;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: dotSize * 1.2,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.dots, (i) {
              final t = phaseOf(_ctrl.value, i * delayFraction);
              final scale = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                const [0.8, 1.2, 0.8],
                curve: Curves.easeInOut,
              );
              final opacity = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                const [0.5, 1.0, 0.5],
                curve: Curves.easeInOut,
              );
              return Padding(
                padding: EdgeInsets.only(right: i < widget.dots - 1 ? gap : 0),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
