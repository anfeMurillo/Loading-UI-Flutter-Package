import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// Two cartoon eyes that blink and look left-right.
///
/// Each eye has a pupil that travels horizontally while a periodic blink
/// closes the eyelid, giving a playful "thinking" expression.
/// Respects [MediaQueryData.disableAnimations].
class WanderingEyesLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double eyeScale;
  final double gapScale;
  final double pupilScale;
  final double blinkScale;
  final double travelScale;
  final String? semanticsLabel;

  const WanderingEyesLoader({
    super.key,
    this.size = 48.0,
    this.color,
    this.duration = const Duration(milliseconds: 10000),
    this.eyeScale = 0.62,
    this.gapScale = 0.09,
    this.pupilScale = 0.32,
    this.blinkScale = 0.375,
    this.travelScale = 0.3125,
    this.semanticsLabel,
  });

  @override
  State<WanderingEyesLoader> createState() => _WanderingEyesLoaderState();
}

class _WanderingEyesLoaderState extends State<WanderingEyesLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(WanderingEyesLoader oldWidget) {
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

  // Returns pupil offset (dx, dy) relative to eye center, in eye units.
  Offset _pupilOffset(double t, double travel) {
    if (t < 0.10) return Offset.zero;
    if (t < 0.13) return Offset(-travel * (t - 0.10) / 0.03, 0);
    if (t < 0.40) return Offset(-travel, 0);
    if (t < 0.43) {
      final s = (t - 0.40) / 0.03;
      return Offset(-travel + 2 * travel * s, 0);
    }
    if (t < 0.70) return Offset(travel, 0);
    if (t < 0.73) {
      final s = (t - 0.70) / 0.03;
      return Offset(travel - travel * s, travel * s);
    }
    if (t < 0.90) return Offset(0, travel);
    if (t < 0.93) return Offset(0, travel * (1 - (t - 0.90) / 0.03));
    return Offset.zero;
  }

  bool _isBlinking(double t) {
    const blinkPoints = [0.11, 0.21, 0.41, 0.61, 0.71, 0.91, 0.99];
    for (final bp in blinkPoints) {
      if ((t - bp).abs() < 0.010) return true;
    }
    return false;
  }

  Widget _buildEye(BuildContext context, double t, Color c, double eyeSize) {
    final eyeColor = c.withValues(alpha: c.a * 0.16);
    final pupilSize = eyeSize * widget.pupilScale.clamp(0.12, 0.45);
    final travel = eyeSize * widget.travelScale.clamp(0.08, 0.5);
    final offset = _pupilOffset(t, travel);
    final blinking = _isBlinking(t);
    final eyeHeight = blinking
        ? eyeSize * widget.blinkScale.clamp(0.15, 1.0)
        : eyeSize;

    return ClipOval(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 30),
        width: eyeSize,
        height: eyeHeight,
        decoration: BoxDecoration(color: eyeColor, shape: BoxShape.circle),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: (eyeSize - pupilSize) / 2 + offset.dx,
              top: (eyeSize - pupilSize) / 2 + offset.dy,
              child: Container(
                width: pupilSize,
                height: pupilSize,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    final h = widget.size;
    final eyeSize = (h * widget.eyeScale.clamp(0.28, 0.7));
    final gap = h * widget.gapScale.clamp(0.04, 0.3);
    final totalW = 2 * eyeSize + gap;

    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) {
            final t = _ctrl.value;
            return SizedBox(
              width: totalW,
              height: h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildEye(ctx, t, c, eyeSize),
                  SizedBox(width: gap),
                  _buildEye(ctx, t, c, eyeSize),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
