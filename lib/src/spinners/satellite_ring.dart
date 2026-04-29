import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A faded ring with a small satellite dot attached at its edge.
///
/// The ring and dot rotate together as a single unit.
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
    // Fixed 2px stroke matches CSS `border-2` and keeps the gap between
    // the ring stroke and the satellite dot stable at any size.
    final stroke = widget.strokeWidth ?? 2.0;
    final dot = widget.size * 0.33333;
    // Place the dot centre exactly on the ring stroke. Match the original
    // CSS angle (top:0, left:0 + translate(-50%, 50%) → upper-left), but
    // reproject onto the stroke-centre radius so the ring line passes
    // through the dot's centre, not just outside it.
    final ringR = (widget.size - stroke) / 2;
    final cx0 = widget.size / 2;
    final cy0 = widget.size / 2;
    // Original CSS positions dot centre at (0, size/3); take that direction.
    final angle = math.atan2(widget.size / 3 - cy0, 0 - cx0);
    final dotCx = cx0 + ringR * math.cos(angle);
    final dotCy = cy0 + ringR * math.sin(angle);
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
              left: dotCx - dot / 2,
              top: dotCy - dot / 2,
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
