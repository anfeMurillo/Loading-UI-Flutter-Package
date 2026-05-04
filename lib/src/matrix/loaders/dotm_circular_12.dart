import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class ArcBeaconLoader extends StatelessWidget {
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

  const ArcBeaconLoader({
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

  static const int _stepCount = 36;
  static const double _baseOpacity = 0.06;
  static const double _midOpacity = 0.3;
  static const double _arcOpacity = 0.96;

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
        final ring = math.sqrt(x * x + y * y);
        final angle = math.atan2(y, x);
        final step = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0
            : (ctx.cyclePhase * _stepCount).floor() % _stepCount;
        final stepBand = ((step / _stepCount) * 8).floor() % 8;
        final targetAngle = stepBand * (math.pi / 4);
        final angleDelta = math.acos(math.cos(angle - targetAngle));
        final beam = (1 - angleDelta / 0.42).clamp(0.0, 1.0);
        final oppositeBeam =
            (1 - math.acos(math.cos(angle - (targetAngle + math.pi))) / 0.62)
                .clamp(0.0, 1.0);
        final spokePulse =
            (1 - (x.abs() - y.abs()).abs() / 0.35).clamp(0.0, 1.0);
        final ringTier = ring < 1 ? 0 : ring < 2 ? 1 : 2;

        var opacity = _baseOpacity;
        if (beam > 0.78 && ringTier >= 1) {
          opacity = _arcOpacity;
        } else if (beam > 0.48) {
          opacity = 0.62;
        } else if (oppositeBeam > 0.52 && ringTier == 2) {
          opacity = _midOpacity;
        } else if (spokePulse > 0.9 && ringTier > 0) {
          opacity = _midOpacity;
        }

        if (x == 0 && y == 0) {
          opacity = math.max(opacity, 0.26);
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
