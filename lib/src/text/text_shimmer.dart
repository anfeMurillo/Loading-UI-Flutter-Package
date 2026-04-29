import 'package:flutter/material.dart';
import '../core/loader_base.dart';

/// A text shimmer effect — a bright highlight sweeps across the text.
///
/// Uses [ShaderMask] with a moving [LinearGradient] to paint a shimmer band
/// that travels from right to left over [text]. The [baseColor] is the
/// dimmed rest colour; [shimmerColor] is the highlight.
/// Respects [MediaQueryData.disableAnimations].
class TextShimmerLoader extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color? baseColor;
  final Color? shimmerColor;
  final Duration duration;
  final double spread;
  final String? semanticsLabel;

  const TextShimmerLoader({
    super.key,
    required this.text,
    this.style,
    this.baseColor,
    this.shimmerColor,
    this.duration = const Duration(milliseconds: 2000),
    this.spread = 2.0,
    this.semanticsLabel,
  });

  @override
  State<TextShimmerLoader> createState() => _TextShimmerLoaderState();
}

class _TextShimmerLoaderState extends State<TextShimmerLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TextShimmerLoader oldWidget) {
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

    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            // The shimmer center moves from +1.5 (off right) to -0.5 (off left).
            final center = 1.5 - _ctrl.value * 2.0;
            // Spread: N characters × spread factor, normalised to ~0.2 of width.
            const spreadFrac = 0.25;
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [base, shimmer, base],
                stops: [
                  (center - spreadFrac).clamp(0.0, 1.0),
                  center.clamp(0.0, 1.0),
                  (center + spreadFrac).clamp(0.0, 1.0),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                widget.text,
                style: textStyle.copyWith(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
