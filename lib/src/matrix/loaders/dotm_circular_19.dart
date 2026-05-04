import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class OrbitCellLoader extends StatelessWidget {
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

  const OrbitCellLoader({
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

  static const double _baseOpacity = 0.07;
  static const double _midOpacity = 0.34;
  static const double _highOpacity = 0.95;

  static const _orbitPoints = [
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 3),
    (3, 3),
    (3, 2),
    (3, 1),
    (2, 1),
  ];

  @override
  Widget build(BuildContext context) {
    final orbitLen = _orbitPoints.length;

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
            : (ctx.cyclePhase * orbitLen).floor() % orbitLen;
        final (headRow, headCol) = _orbitPoints[t];
        final (tailRow, tailCol) =
            _orbitPoints[(t + orbitLen - 1) % orbitLen];

        var opacity = _baseOpacity;
        if (ctx.row == headRow && ctx.col == headCol) {
          opacity = _highOpacity;
        } else if (ctx.row == tailRow && ctx.col == tailCol) {
          opacity = 0.62;
        } else if ((ctx.col == 1 || ctx.col == 3) &&
            (ctx.row == 1 || ctx.row == 2 || ctx.row == 3)) {
          opacity = _midOpacity;
        } else if (ctx.row == 2 && ctx.col == 2) {
          opacity = 0.2;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
