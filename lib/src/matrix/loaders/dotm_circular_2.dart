import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';
import '../styles.dart';

class TriOrbitLoader extends StatelessWidget {
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

  const TriOrbitLoader({
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

  static const _ringPath = [
    1, 2, 3,       // (0,1)-(0,3)
    9, 14, 19,     // (1,4)-(3,4)
    23, 22, 21,    // (4,3)-(4,1)
    15, 10, 5,     // (3,0)-(1,0)
  ];

  static const int _loopLen = 12;
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

        final onRing = _ringPath.indexOf(ctx.index);
        if (onRing == -1) {
          return DotAnimationState(
              opacity: ctx.row == 2 && ctx.col == 2 ? 0.18 : 0.08);
        }

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return DotAnimationState(
              opacity: 0.28 + (onRing / (_loopLen - 1)) * 0.58);
        }

        final t = (ctx.cyclePhase + onRing / _loopLen) % 1.0;
        return DotAnimationState(
            opacity: circularRingOpacity(t, _base, _mid, _peak));
      },
    );
  }
}
