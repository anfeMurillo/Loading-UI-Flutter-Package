import 'package:flutter/material.dart';
import '../core/loader_base.dart';

/// A shimmer skeleton placeholder.
///
/// Renders a rounded rectangle that pulses in opacity, signalling that
/// content is being loaded. Use [width] and [height] to size it to the
/// expected content area. Respects [MediaQueryData.disableAnimations].
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius borderRadius;
  final Duration duration;
  final String? semanticsLabel;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.duration = const Duration(milliseconds: 2000),
    this.semanticsLabel,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 50),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
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
    final fill =
        widget.color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: _opacity,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: widget.borderRadius,
            ),
          ),
        ),
      ),
    );
  }
}
