import 'package:flutter/material.dart';

import '../grid_paths.dart';
import '../matrix_base.dart';
import '../styles.dart';

class TwinOrbitMatrixLoader extends StatelessWidget {
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

  const TwinOrbitMatrixLoader({
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

  static const double _base = 0.16;
  static const double _mid = 0.32;
  static const double _peak = 1.0;

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

        final isCenter = ctx.row == 2 && ctx.col == 2;
        if (isCenter) return null;

        final outerOrder = outerRingClockwiseOrderValue(ctx.index);
        if (outerOrder >= 0) {
          final outerNorm = outerRingClockwiseNormFromIndex(ctx.index);
          if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
            return DotAnimationState(
                opacity: 0.2 + outerNorm * 0.72);
          }
          final t = (ctx.cyclePhase - outerOrder * 0.0625) % 1.0;
          return DotAnimationState(
              opacity: ringSnakeOpacity(t, _base, _mid, _peak));
        }

        final middleOrder =
            middleRingAntiClockwiseOrderValue(ctx.index);
        final middleNorm =
            middleRingAntiClockwiseNormFromIndex(ctx.index);
        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return DotAnimationState(
              opacity: 0.2 + middleNorm * 0.72);
        }

        final t = (ctx.cyclePhase - middleOrder * 0.125) % 1.0;
        return DotAnimationState(
            opacity: ringSnakeOpacity(t, _base, _mid, _peak));
      },
    );
  }
}
