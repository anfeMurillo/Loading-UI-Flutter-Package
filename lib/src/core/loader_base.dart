import 'package:flutter/material.dart';

/// A base wrapper for all loading indicators to ensure consistent
/// accessibility and performance across the library.
/// 
/// Wraps the [child] with [Semantics] for screen readers and 
/// [RepaintBoundary] to optimize animation performance.
class LoaderWrapper extends StatelessWidget {
  /// The animation or drawing to be displayed.
  final Widget child;

  /// The accessibility label for the loader. Defaults to 'Loading'.
  final String? semanticsLabel;

  /// The size of the loader. If provided, wraps the child in a [SizedBox.square].
  final double? size;

  const LoaderWrapper({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (size != null) {
      current = SizedBox.square(
        dimension: size,
        child: current,
      );
    }

    return Semantics(
      label: semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: current,
      ),
    );
  }
}

/// A helper mixin for loaders that require a staggered animation interval.
mixin StaggeredAnimationMixin {
  /// Calculates an [Interval] for a staggered animation.
  Interval staggeredInterval(int index, int total, {Curve curve = Curves.linear}) {
    final double start = index / total;
    return Interval(
      start,
      1.0,
      curve: curve,
    );
  }
}
