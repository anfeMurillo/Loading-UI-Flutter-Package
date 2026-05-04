import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class RadarArcLoader extends StatelessWidget {
  final double? size;
  final double? dotSize;
  final Color? color;
  final double speed;
  final String? semanticsLabel;
  final bool animated;
  final bool hoverAnimated;
  final double? opacityBase;
  final double? opacityMid;
  final double? opacityPeak;
  final double? cellPadding;
  final double? boxSize;
  final double? minSize;

  const RadarArcLoader({
    super.key,
    this.size,
    this.dotSize,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel = 'Loading',
    this.animated = true,
    this.hoverAnimated = false,
    this.opacityBase,
    this.opacityMid,
    this.opacityPeak,
    this.cellPadding,
    this.boxSize,
    this.minSize,
  });

  static const double _baseOpacity = 0.08;
  static const double _sweepOpacity = 0.96;
  static const double _nearSweepOpacity = 0.36;
  static const double _ringOpacity = 0.22;

  @override
  Widget build(BuildContext context) {
    return DotMatrixBase(
      size: size,
      dotSize: dotSize,
      color: color,
      speed: speed,
      semanticsLabel: semanticsLabel,
      pattern: MatrixPattern.full,
      animated: animated,
      hoverAnimated: hoverAnimated,
      opacityBase: opacityBase,
      opacityMid: opacityMid,
      opacityPeak: opacityPeak,
      cellPadding: cellPadding,
      boxSize: boxSize,
      minSize: minSize,
      animationResolver: (ctx) {
        if (!isWithinCircularMask(ctx.row, ctx.col)) return null;

        final centerRow = ctx.row - 2;
        final centerCol = ctx.col - 2;
        final radius =
            math.sqrt(centerRow * centerRow + centerCol * centerCol);
        final theta =
            (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
                    ? 0.0
                    : ctx.cyclePhase) *
                math.pi *
                2;
        final sweepX = math.cos(theta);
        final sweepY = math.sin(theta);
        final projection =
            centerCol * sweepX + centerRow * sweepY;
        final perpendicular =
            (centerCol * sweepY - centerRow * sweepX).abs();

        if (radius < 0.5) {
          return const DotAnimationState(opacity: 0.62);
        }

        if (projection > 0.3 && perpendicular < 0.55) {
          return const DotAnimationState(opacity: _sweepOpacity);
        }

        if (projection > 0 && perpendicular < 1.15) {
          return const DotAnimationState(opacity: _nearSweepOpacity);
        }

        if (radius > 1.6 && radius < 2.3) {
          return const DotAnimationState(opacity: _ringOpacity);
        }

        return const DotAnimationState(opacity: _baseOpacity);
      },
    );
  }
}
