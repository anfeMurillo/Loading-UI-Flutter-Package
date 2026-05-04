import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class NovaWheelLoader extends StatelessWidget {
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

  const NovaWheelLoader({
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
  static const double _bladeOpacity = 0.94;
  static const double _haloOpacity = 0.34;

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
        final radius = math.sqrt(x * x + y * y);
        final angle = math.atan2(y.toDouble(), x.toDouble());
        final theta =
            (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
                    ? 0.0
                    : ctx.cyclePhase) *
                math.pi *
                2;
        final pinwheel =
            math.cos(angle * 4 - theta * 2.2);
        final radialGate =
            math.sin(radius * 2.1 - theta * 1.25);

        if (radius < 0.6) {
          return const DotAnimationState(opacity: 0.66);
        }

        if (pinwheel > 0.48 && radialGate > -0.25) {
          return const DotAnimationState(opacity: _bladeOpacity);
        }

        if (pinwheel > 0.1) {
          return const DotAnimationState(opacity: _haloOpacity);
        }

        return const DotAnimationState(opacity: _baseOpacity);
      },
    );
  }
}
