import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// A row of dots that fade in and out in sequence.
///
/// Each dot's opacity is driven by [phaseOf] with an evenly-distributed
/// phase offset. Commonly used as an ellipsis-style thinking indicator.
/// Respects [MediaQueryData.disableAnimations].
class DotsLoader extends StatefulWidget {
  final double size;
  final int dots;
  final Color? color;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const DotsLoader({
    super.key,
    this.size = 32.0,
    this.dots = 3,
    this.color,
    this.duration = const Duration(milliseconds: 1400),
    this.delay = const Duration(milliseconds: 200),
    this.semanticsLabel,
  });

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(DotsLoader oldWidget) {
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
    final gap = widget.size * 0.12;
    final dotSize = (widget.size - gap * (widget.dots - 1)) / widget.dots;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: dotSize,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.dots, (i) {
              final t = phaseOf(_ctrl.value, i * delayFraction);
              final opacity = lerpStops(
                t,
                const [0.0, 0.2, 1.0],
                const [0.2, 1.0, 0.2],
              );
              return Padding(
                padding: EdgeInsets.only(right: i < widget.dots - 1 ? gap : 0),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
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
