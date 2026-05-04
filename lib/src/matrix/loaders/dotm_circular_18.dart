import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class PulsePairLoader extends StatelessWidget {
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

  const PulsePairLoader({
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
  static const double _midOpacity = 0.33;
  static const double _highOpacity = 0.95;

  static const _pairCols = {1, 3};

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
            : (ctx.cyclePhase * 6).floor();
        final pulseRow = t % 3;
        final topRow = pulseRow;
        final bottomRow = 4 - pulseRow;

        var opacity = _baseOpacity;
        if ((ctx.row == topRow || ctx.row == bottomRow) &&
            _pairCols.contains(ctx.col)) {
          opacity = _highOpacity;
        } else if ((ctx.row == topRow || ctx.row == bottomRow) &&
            ctx.col == 2) {
          opacity = 0.58;
        } else if ((ctx.row == 2 || ctx.col == 2) &&
            !_pairCols.contains(ctx.col)) {
          opacity = _midOpacity;
        } else if (_pairCols.contains(ctx.col)) {
          opacity = 0.22;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
