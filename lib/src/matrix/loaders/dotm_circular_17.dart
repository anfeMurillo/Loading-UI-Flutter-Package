import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class CheckerShiftLoader extends StatelessWidget {
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

  const CheckerShiftLoader({
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

  static const int _checkerSteps = 4;
  static const double _baseOpacity = 0.07;
  static const double _midOpacity = 0.34;
  static const double _highOpacity = 0.95;

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
            ? 0
            : (ctx.cyclePhase * _checkerSteps).floor() % _checkerSteps;
        final parity = (ctx.row + ctx.col + t) % 2;
        final brailleBias = ctx.col == 1 || ctx.col == 3;
        final centerBias = ctx.row == 2 || ctx.col == 2;

        var opacity = _baseOpacity;
        if (parity == 0 && brailleBias) {
          opacity = _highOpacity;
        } else if (parity == 0 || centerBias) {
          opacity = _midOpacity;
        } else if (brailleBias) {
          opacity = 0.24;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
