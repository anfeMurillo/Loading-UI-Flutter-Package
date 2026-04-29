import 'package:flutter/material.dart';

class LoaderWrapper extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
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
      current = SizedBox.square(dimension: size, child: current);
    }
    return Semantics(
      container: true,
      label: semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(child: current),
    );
  }
}

bool reducedMotionOf(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

mixin LoaderAnimationMixin<T extends StatefulWidget> on State<T> {
  AnimationController get controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void syncMotion() => _syncMotion();

  void _syncMotion() {
    if (reducedMotionOf(context)) {
      if (controller.isAnimating) controller.stop();
      controller.value = 0.0;
    } else if (!controller.isAnimating) {
      controller.repeat();
    }
  }
}

mixin StaggeredAnimationMixin {
  Interval staggeredInterval(
    int index,
    int total, {
    Curve curve = Curves.linear,
  }) {
    final double start = index / total;
    return Interval(start, 1.0, curve: curve);
  }
}
