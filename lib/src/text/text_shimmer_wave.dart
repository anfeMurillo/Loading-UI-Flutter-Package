import 'package:flutter/material.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// Per-character shimmer wave — each letter rises, scales, and brightens.
///
/// Each character is independently transformed (Y-offset, scale, colour)
/// with a staggered [phaseOf] delay, creating a wave that sweeps across the
/// [text]. Respects [MediaQueryData.disableAnimations].
class TextShimmerWaveLoader extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color? baseColor;
  final Color? shimmerColor;
  final Duration duration;
  final double spread;
  final double yDistance;
  final double scaleDistance;
  final String? semanticsLabel;

  const TextShimmerWaveLoader({
    super.key,
    required this.text,
    this.style,
    this.baseColor,
    this.shimmerColor,
    this.duration = const Duration(milliseconds: 1000),
    this.spread = 1.0,
    this.yDistance = -2.0,
    this.scaleDistance = 1.1,
    this.semanticsLabel,
  });

  @override
  State<TextShimmerWaveLoader> createState() => _TextShimmerWaveLoaderState();
}

class _TextShimmerWaveLoaderState extends State<TextShimmerWaveLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TextShimmerWaveLoader oldWidget) {
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
    final textStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final base =
        widget.baseColor ??
        (textStyle.color ?? Colors.black).withValues(alpha: 0.55);
    final shimmer = widget.shimmerColor ?? textStyle.color ?? Colors.black;
    final chars = widget.text.split('');
    final n = chars.length;
    // repeat delay factor (mimic repeatDelay: n * 0.05 / spread).
    final repeatDelay = (n * 0.05) / widget.spread;
    final totalCycle = 1.0 + repeatDelay;

    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: List.generate(n, (i) {
              final delayFrac =
                  (i / n) * (1.0 / totalCycle) * (1.0 / widget.spread);
              final t = phaseOf(_ctrl.value / totalCycle, delayFrac);
              // clamp 0..1
              final tc = t.clamp(0.0, 1.0);
              final tEased = Curves.easeInOut.transform(tc);

              final dy = lerpStops(
                tEased,
                const [0.0, 0.5, 1.0],
                [0.0, widget.yDistance, 0.0],
              );
              final scale = lerpStops(
                tEased,
                const [0.0, 0.5, 1.0],
                [1.0, widget.scaleDistance, 1.0],
              );
              // color interpolation
              final colorT = lerpStops(
                tEased,
                const [0.0, 0.5, 1.0],
                const [0.0, 1.0, 0.0],
              );
              final charColor = Color.lerp(base, shimmer, colorT)!;

              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.scale(
                  scale: scale,
                  child: Text(
                    chars[i] == ' ' ? ' ' : chars[i],
                    style: textStyle.copyWith(color: charColor),
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
