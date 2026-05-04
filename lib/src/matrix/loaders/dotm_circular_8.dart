import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class HeartPulseLoader extends StatelessWidget {
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

  const HeartPulseLoader({
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
  static const double _pulseCore = 0.95;
  static const double _pulseRing = 0.44;

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

        final x = ctx.col - 2;
        final y = ctx.row - 2;
        final radius = math.sqrt((x * x + y * y).toDouble());
        final beat = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : math.sin(ctx.cyclePhase * math.pi * 2);
        final spike = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : math.sin(ctx.cyclePhase * math.pi * 4);
        final pulse = (beat > 0 ? beat : 0.0) +
            (spike > 0 ? spike : 0.0) * 0.55;

        if (radius < 0.55) {
          return DotAnimationState(
              opacity: (0.35 + pulse * _pulseCore)
                  .clamp(0.0, 1.0)
                  .toDouble());
        }
        if (radius < 1.65) {
          return DotAnimationState(
              opacity: (0.16 + pulse * _pulseRing)
                  .toDouble());
        }
        return DotAnimationState(
            opacity: (_baseOpacity + pulse * 0.08).toDouble());
      },
    );
  }
}
