import 'package:flutter/material.dart';

import '../matrix_base.dart';
import '../styles.dart';

class OriginWaveLoader extends StatelessWidget {
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

  const OriginWaveLoader({
    super.key,
    this.size,
    this.dotSize,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel = 'Loading',
    this.pattern = MatrixPattern.full,
    this.animated = true,
    this.hoverAnimated = false,
    this.opacityBase,
    this.opacityMid,
    this.opacityPeak,
    this.cellPadding,
    this.boxSize,
    this.minSize,
  });

  @override
  Widget build(BuildContext context) {
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

        const originRow = 1;
        const originCol = 1;
        const maxManhattan = 6;

        final ring = (ctx.row - originRow).abs() +
            (ctx.col - originCol).abs();
        final clampedRing = ring.clamp(0, maxManhattan);

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return DotAnimationState(
            opacity: 0.2 + (1 - clampedRing / maxManhattan) * 0.75,
          );
        }

        final t = (ctx.cyclePhase + clampedRing * 0.16) % 1.0;
        return DotAnimationState(
          opacity: centerOriginRippleOpacity(t, 0.16, 0.32, 1.0),
        );
      },
    );
  }
}
