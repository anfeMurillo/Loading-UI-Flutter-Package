import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A ring with a small satellite dot orbiting it.
///
/// Combines a spinning ring stroke with a smaller dot that orbits at a
/// slightly different speed, creating a satellite effect.
/// Respects [MediaQueryData.disableAnimations].
class SatelliteRingLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const SatelliteRingLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<SatelliteRingLoader> createState() => _SatelliteRingLoaderState();
}

class _SatelliteRingLoaderState extends State<SatelliteRingLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(SatelliteRingLoader oldWidget) {
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
    final stroke = widget.strokeWidth ?? 2.0 * (widget.size / 24);
    final dot = widget.size * 0.33333;
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _ctrl,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c.withValues(alpha: c.a * 0.25),
                    width: stroke,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -dot / 2,
              top: dot / 2,
              width: dot,
              height: dot,
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: c),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
