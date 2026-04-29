import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A filled dot that pulses in scale and opacity.
///
/// The dot grows then shrinks with an eased scale animation, and
/// simultaneously fades out then back in, creating a breathing pulse.
/// Respects [MediaQueryData.disableAnimations].
class PulseDotLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const PulseDotLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.semanticsLabel,
  });

  @override
  State<PulseDotLoader> createState() => _PulseDotLoaderState();
}

class _PulseDotLoaderState extends State<PulseDotLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 50),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(PulseDotLoader oldWidget) {
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
              decoration: BoxDecoration(shape: BoxShape.circle, color: c),
            ),
          ),
        ),
      ),
    );
  }
}
