import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Vertical bars that animate up and down in a staggered sequence.
///
/// Each bar scales vertically with a phase offset, producing an equaliser-
/// like animation. Respects [MediaQueryData.disableAnimations].
class BarsLoader extends StatefulWidget {
  final double size;
  final int bars;
  final Color? color;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const BarsLoader({
    super.key,
    this.size = 32.0,
    this.bars = 3,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.delay = const Duration(milliseconds: 200),
    this.semanticsLabel,
  });

  @override
  State<BarsLoader> createState() => _BarsLoaderState();
}

class _BarsLoaderState extends State<BarsLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(BarsLoader oldWidget) {
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
    final gap = widget.size * 0.05 / (widget.bars + 1);
    final barWidth = (widget.size - gap * (widget.bars - 1)) / widget.bars;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(widget.bars, (i) {
              final t = phaseOf(_ctrl.value, i * delayFraction);
              final scaleY = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                const [1.0, 0.6, 1.0],
                curve: Curves.easeInOut,
              );
              final opacity = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                const [0.5, 1.0, 0.5],
                curve: Curves.easeInOut,
              );
              return Padding(
                padding: EdgeInsets.only(right: i < widget.bars - 1 ? gap : 0),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scaleY: scaleY,
                    child: Container(
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(1),
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
