import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A clock-hand sweep spinner.
///
/// Animates a filled arc that sweeps around the ring like a clock hand,
/// producing a "filling" effect on each cycle.
/// Respects [MediaQueryData.disableAnimations].
class ClockRingLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const ClockRingLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<ClockRingLoader> createState() => _ClockRingLoaderState();
}

class _ClockRingLoaderState extends State<ClockRingLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(ClockRingLoader oldWidget) {
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
    // Fixed 2px stroke matches CSS `border-2`; the original border width
    // does not scale with element size.
    final stroke = widget.strokeWidth ?? 2.0;
    final handWidth = widget.size * 0.0625;
    final handHeight = widget.size * 0.5;
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _ctrl,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c, width: stroke),
              ),
            ),
            Positioned(
              top: 0,
              left: (widget.size - handWidth) / 2,
              child: Container(width: handWidth, height: handHeight, color: c),
            ),
          ],
        ),
      ),
    );
  }
}
