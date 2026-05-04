import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class GateShiftLoader extends StatelessWidget {
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

  const GateShiftLoader({
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
  static const double _gateOpacity = 0.92;

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
        final t = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : ctx.cyclePhase * math.pi * 2;
        final ring = math.sqrt((x * x + y * y).toDouble());
        final angle = math.atan2(y.toDouble(), x.toDouble());

        final petalWave =
            0.5 + 0.5 * math.cos(5 * angle - t * 1.7);
        final ringWave =
            0.5 + 0.5 * math.cos(ring * 3.3 - t * 1.2);
        final chordWave =
            0.5 + 0.5 * math.cos((x + y) * 1.6 + t * 1.35);

        final petalGate = math.pow(petalWave, 2.2).toDouble();
        final blend = 0.68 * petalGate +
            0.22 * ringWave +
            0.1 * chordWave;
        final opacity =
            _baseOpacity + (_gateOpacity - _baseOpacity) * blend;

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
