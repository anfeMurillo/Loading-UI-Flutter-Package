import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class HaloDriftLoader extends StatelessWidget {
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

  const HaloDriftLoader({
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
  static const double _strandOpacity = 1.0;
  static const double _nearStrandOpacity = 0.24;
  static const double _stepCount = 20.0;
  static const double _helixLoopRadians = math.pi * 2 / (_stepCount - 1);

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

        final t = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : ctx.cyclePhase * _stepCount;
        final diagonalAxis = ctx.row + ctx.col;
        final phaseOffset =
            t * _helixLoopRadians + diagonalAxis * 0.82;
        final strandPerpendicular =
            (2 * math.sin(phaseOffset)).round();
        final cellPerpendicular = ctx.col - ctx.row;
        final distanceFromStrand =
            (cellPerpendicular - strandPerpendicular).abs();

        if (distanceFromStrand == 0) {
          return const DotAnimationState(opacity: _strandOpacity);
        }
        if (distanceFromStrand == 1) {
          return const DotAnimationState(opacity: _nearStrandOpacity);
        }
        return const DotAnimationState(opacity: _baseOpacity);
      },
    );
  }
}
