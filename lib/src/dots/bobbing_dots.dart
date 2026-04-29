import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Dots that bob up and down gently.
///
/// Similar to [BouncingDotsLoader] but with a softer easing, giving a
/// floating "bobbing" feel rather than a hard bounce.
/// Respects [MediaQueryData.disableAnimations].
class BobbingDotsLoader extends StatefulWidget {
  final double size;
  final int dots;
  final Color? color;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const BobbingDotsLoader({
    super.key,
    this.size = 32.0,
    this.dots = 3,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = const Duration(milliseconds: 200),
    this.semanticsLabel,
  });

  @override
  State<BobbingDotsLoader> createState() => _BobbingDotsLoaderState();
}

class _BobbingDotsLoaderState extends State<BobbingDotsLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(BobbingDotsLoader oldWidget) {
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
    final maxOffset = dotSize * 0.625;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: dotSize + maxOffset,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.dots, (i) {
              final t = phaseOf(_ctrl.value, i * delayFraction);
              final offset = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                [0.0, maxOffset, 0.0],
                curve: Curves.easeInOut,
              );
              return Padding(
                padding: EdgeInsets.only(right: i < widget.dots - 1 ? gap : 0),
                child: Transform.translate(
                  offset: Offset(0, offset),
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c,
                      boxShadow: const [
                        BoxShadow(blurRadius: 1, offset: Offset(0, 1)),
                      ],
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
