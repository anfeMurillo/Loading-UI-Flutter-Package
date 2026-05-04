import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class TwinHelixLoader extends StatelessWidget {
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

  const TwinHelixLoader({
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

  static const int _stepCount = 28;
  static const double _baseOpacity = 0.07;
  static const double _strandOpacity = 0.95;
  static const double _nearStrandOpacity = 0.5;
  static const double _bridgeOpacity = 0.3;

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

        final x = ctx.col - 2.0;
        final y = ctx.row - 2.0;
        final step = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0
            : (ctx.cyclePhase * _stepCount).floor() % _stepCount;
        final t = (step / _stepCount) * math.pi * 2;

        final strandOffset = math.sin(y * 1.35 + t * 1.3) * 1.15;
        final leftStrand = -strandOffset;
        final rightStrand = strandOffset;
        final leftDistance = (x - leftStrand).abs();
        final rightDistance = (x - rightStrand).abs();
        final strandDistance = math.min(leftDistance, rightDistance);

        final bridgeOn = math.cos(y * 2 + t * 2.1) > 0.55;
        final isBetweenStrands =
            x > math.min(leftStrand, rightStrand) &&
                x < math.max(leftStrand, rightStrand);

        var opacity = _baseOpacity;
        if (strandDistance < 0.34) {
          opacity = _strandOpacity;
        } else if (strandDistance < 0.8) {
          opacity = _nearStrandOpacity;
        } else if (bridgeOn && isBetweenStrands) {
          opacity = _bridgeOpacity;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
