import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// A three-dot typing indicator (chat bubble style).
///
/// Mimics the "someone is typing" indicator used in messaging apps — three
/// dots fade and scale with a staggered phase offset.
/// Respects [MediaQueryData.disableAnimations].
class TypingLoader extends StatefulWidget {
  final double size;
  final int dots;
  final Color? color;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const TypingLoader({
    super.key,
    this.size = 32.0,
    this.dots = 3,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = const Duration(milliseconds: 160),
    this.semanticsLabel,
  });

  @override
  State<TypingLoader> createState() => _TypingLoaderState();
}

class _TypingLoaderState extends State<TypingLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TypingLoader oldWidget) {
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
    final maxLift = dotSize * 0.5;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: dotSize + maxLift,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.dots, (i) {
              final t = phaseOf(_ctrl.value, i * delayFraction);
              final offset = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                [0.0, -maxLift, 0.0],
              );
              final opacity = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                const [0.5, 1.0, 0.5],
              );
              return Padding(
                padding: EdgeInsets.only(right: i < widget.dots - 1 ? gap : 0),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, offset),
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
