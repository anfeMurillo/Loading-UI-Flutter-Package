import 'package:flutter/material.dart';

import '../matrix_base.dart';
import '../styles.dart';

class DotMatrixIcon extends StatelessWidget {
  final double? size;
  final double? dotSize;
  final Color? color;
  final double speed;
  final String? semanticsLabel;
  final MatrixPattern pattern;
  final bool animated;
  final bool hoverAnimated;
  final double? opacityBase;
  final double? opacityMid;
  final double? opacityPeak;
  final double? cellPadding;
  final double? boxSize;
  final double? minSize;

  const DotMatrixIcon({
    super.key,
    this.size = 24.0,
    this.dotSize = 3.0,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel = 'Loading',
    this.pattern = MatrixPattern.diamond,
    this.animated = false,
    this.hoverAnimated = true,
    this.opacityBase,
    this.opacityMid,
    this.opacityPeak,
    this.cellPadding,
    this.boxSize,
    this.minSize,
  });

  static const double _base = 0.22;
  static const double _mid = 0.55;
  static const double _peak = 0.96;

  @override
  Widget build(BuildContext context) {
    final base = opacityBase ?? _base;
    final mid = opacityMid ?? _mid;
    final peak = opacityPeak ?? _peak;

    return DotMatrixBase(
      size: size,
      dotSize: dotSize,
      color: color,
      speed: speed,
      semanticsLabel: semanticsLabel,
      pattern: pattern,
      animated: animated,
      hoverAnimated: hoverAnimated,
      opacityBase: opacityBase,
      opacityMid: opacityMid,
      opacityPeak: opacityPeak,
      cellPadding: cellPadding,
      boxSize: boxSize,
      minSize: minSize,
      animationResolver: (ctx) {
        if (!ctx.isActive) return null;

        if (ctx.reducedMotion) {
          return const DotAnimationState(opacity: _base);
        }

        final phase = ctx.phase;
        final t = ctx.cyclePhase;
        final ring = ctx.distanceFromCenter.round();

        if (phase == DotMatrixPhase.loadingRipple) {
          final ringOffset = (ring * 0.12) % 1.0;
          final delayedT = (t - ringOffset + 1.0) % 1.0;
          return DotAnimationState(
            opacity: rippleOpacity(delayedT, base, peak),
          );
        }

        if (phase == DotMatrixPhase.collapse) {
          return DotAnimationState(
            opacity: collapseOpacity(t, base, mid, peak),
          );
        }

        if (phase == DotMatrixPhase.hoverRipple) {
          return DotAnimationState(
            opacity: hoverRippleOpacity(t, base, peak),
          );
        }

        return const DotAnimationState(opacity: _base);
      },
    );
  }
}
