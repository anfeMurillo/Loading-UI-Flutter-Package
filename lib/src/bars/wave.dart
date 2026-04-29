import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Bars animated in a smooth sine-wave pattern.
///
/// Like [BarsLoader] but uses a smoother sine-wave phase curve, giving a
/// flowing water-wave appearance. Respects [MediaQueryData.disableAnimations].
class WaveLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const WaveLoader({
    super.key,
    this.size = 32.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = const Duration(milliseconds: 100),
    this.semanticsLabel,
  });

  @override
  State<WaveLoader> createState() => _WaveLoaderState();
}

const _waveHeights = [0.5, 0.75, 1.0, 0.75, 0.5];

class _WaveLoaderState extends State<WaveLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(WaveLoader oldWidget) {
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
    final barWidth = widget.size * 0.125;
    final gap = widget.size * 0.025;

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_waveHeights.length, (i) {
              final t = phaseOf(_ctrl.value, i * delayFraction);
              final scaleY = lerpStops(
                t,
                const [0.0, 0.5, 1.0],
                const [1.0, 0.6, 1.0],
                curve: Curves.easeInOut,
              );
              return Padding(
                padding: EdgeInsets.only(
                  right: i < _waveHeights.length - 1 ? gap : 0,
                ),
                child: Transform.scale(
                  scaleY: scaleY,
                  child: Container(
                    width: barWidth,
                    height: widget.size * _waveHeights[i],
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(barWidth),
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
