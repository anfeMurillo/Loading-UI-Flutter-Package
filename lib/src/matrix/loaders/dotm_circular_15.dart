import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class GlyphClusterLoader extends StatelessWidget {
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

  const GlyphClusterLoader({
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

  static const List<Set<(int, int)>> _braillePhases = [
    {(1, 1), (2, 1), (3, 1), (1, 3), (2, 3), (3, 3)},
    {(1, 1), (2, 1), (3, 1), (2, 2), (1, 3), (2, 3), (3, 3)},
    {(1, 1), (1, 2), (1, 3), (2, 1), (2, 3), (3, 1), (3, 2), (3, 3)},
    {(1, 1), (3, 1), (2, 2), (1, 3), (3, 3)},
    {(2, 1), (1, 2), (3, 2), (2, 3)},
    {(1, 1), (2, 1), (2, 2), (2, 3), (3, 3)},
  ];

  @override
  Widget build(BuildContext context) {
    final count = _braillePhases.length;

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

        final phaseIndex = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0
            : ((ctx.cyclePhase * count).floor() % count);

        final activePattern = _braillePhases[phaseIndex];
        final inPattern = activePattern.contains((ctx.row, ctx.col));

        final previousIndex = (phaseIndex + count - 1) % count;
        final inPrevPattern =
            _braillePhases[previousIndex].contains((ctx.row, ctx.col));

        var opacity = _baseOpacity;
        if (inPattern) {
          opacity = _highOpacity;
        } else if (inPrevPattern) {
          opacity = _midOpacity;
        } else if (ring < 1.1) {
          opacity = 0.2;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
