import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Dots that pulse in scale with a staggered delay.
///
/// Each dot grows from its rest size to a peak then contracts back, with
/// adjacent dots phase-shifted to produce a ripple-like wave.
/// Respects [MediaQueryData.disableAnimations].
class PulsatingDotsLoader extends StatefulWidget {
  final double size;
  final int dots;
  final Color? color;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const PulsatingDotsLoader({
    super.key,
    this.size = 32.0,
    this.dots = 3,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = const Duration(milliseconds: 300),
    this.semanticsLabel,
  });

  @override
  State<PulsatingDotsLoader> createState() => _PulsatingDotsLoaderState();
}

class _PulsatingDotsLoaderState extends State<PulsatingDotsLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(PulsatingDotsLoader oldWidget) {
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
    final gap = widget.size * 0.16;
    final dotSize = (widget.size - gap * (widget.dots - 1)) / widget.dots;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: dotSize * 1.5,
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
                const [1.0, 1.5, 1.0],
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
