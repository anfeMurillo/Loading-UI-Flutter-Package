import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class PhaseOrbLoader extends StatelessWidget {
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

  const PhaseOrbLoader({
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
  static const double _orbitOpacity = 0.96;
  static const double _nearOrbitOpacity = 0.34;

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
        final angle = math.atan2(y.toDouble(), x.toDouble());
        final ring = math.sqrt((x * x + y * y).toDouble());

        final angularPhase =
            ((angle - t * 0.95 + math.pi * 4) % (math.pi * 2)) /
                (math.pi * 2 / 3);
        final sectorPos = angularPhase - angularPhase.floor();
        final sectorPulse = (1 - (sectorPos - 0.5).abs() * 2)
            .clamp(0.0, 1.0);
        final ringPhase =
            0.5 + 0.5 * math.cos(ring * 3.2 + t * 1.7);
        final score = 0.74 * sectorPulse + 0.26 * ringPhase;

        var opacity = _baseOpacity;
        if (score > 0.84) {
          opacity = _orbitOpacity;
        } else if (score > 0.63) {
          opacity = 0.62;
        } else if (score > 0.44) {
          opacity = _nearOrbitOpacity;
        }

        if (x == 0 && y == 0) {
          opacity = opacity > _nearOrbitOpacity
              ? opacity
              : _nearOrbitOpacity;
        }
        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
