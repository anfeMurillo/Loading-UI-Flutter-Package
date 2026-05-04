import 'package:flutter/material.dart';

import '../grid_paths.dart';
import '../matrix_base.dart';
import '../styles.dart';

class CoreSpiralLoader extends StatelessWidget {
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

  const CoreSpiralLoader({
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

        final order = spiralInwardOrderValue(ctx.index);
        final pathNorm = spiralInwardNormFromIndex(ctx.index);

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return DotAnimationState(opacity: 0.16 + pathNorm * 0.78);
        }

        final t = (ctx.cyclePhase + order * 0.04) % 1.0;
        return DotAnimationState(
          opacity: spiralSnakeOpacity(t, 0.16, 0.32, 1.0),
        );
      },
    );
  }
}
