import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class RailScanLoader extends StatelessWidget {
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

  const RailScanLoader({
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

  static const int _stepCount = 25;
  static const double _baseOpacity = 0.07;
  static const double _midOpacity = 0.32;
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
            : (ctx.cyclePhase * _stepCount).floor() % _stepCount;
        final activeRow = t % 5;
        final activeBrailleCol = ((t / 5) * 2).floor() % 2;
        final railCol = activeBrailleCol == 0 ? 1 : 3;
        final nearCol = 2;
        final rowDistance = (ctx.row - activeRow).abs();

        var opacity = _baseOpacity;
        if (ctx.col == railCol && rowDistance == 0) {
          opacity = _highOpacity;
        } else if (ctx.col == railCol && rowDistance == 1) {
          opacity = _midOpacity;
        } else if (ctx.col == nearCol && rowDistance == 0) {
          opacity = 0.52;
        } else if ((ctx.col == 1 || ctx.col == 3) && rowDistance == 2) {
          opacity = 0.24;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
