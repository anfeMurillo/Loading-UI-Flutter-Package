import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A subtle ring pulse loader.
///
/// Scales a bordered circle between 0.95 and 1.05 while fading opacity
/// between 0.8 and 0.4, creating a gentle breathing pulse.
/// Respects [MediaQueryData.disableAnimations].
class PulseLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double? strokeWidth;
  final String? semanticsLabel;

  const PulseLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.strokeWidth,
    this.semanticsLabel,
  });

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 1.05, end: 0.95), weight: 50),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.4), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.8), weight: 50),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(PulseLoader oldWidget) {
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
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c, width: stroke),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
