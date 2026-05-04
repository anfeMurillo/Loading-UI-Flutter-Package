import 'package:flutter/material.dart';

import '../matrix_base.dart';
import '../grid_paths.dart';
import '../styles.dart';

class NeonDriftLoader extends StatelessWidget {
  final double? size;
  final double? dotSize;
  final Color? color;
  final double speed;
  final String? semanticsLabel;
  final MatrixPattern pattern;
  final bool animated;
  final bool hoverAnimated;
  final double? opacityBase;
  final double? opacityMid;
  final double? opacityPeak;
  final double? cellPadding;
  final double? boxSize;
  final double? minSize;

  const NeonDriftLoader({
    super.key,
    this.size,
    this.dotSize,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel = 'Loading',
    this.pattern = MatrixPattern.full,
    this.animated = true,
    this.hoverAnimated = false,
    this.opacityBase,
    this.opacityMid,
    this.opacityPeak,
    this.cellPadding,
    this.boxSize,
    this.minSize,
  });

  @override
  Widget build(BuildContext context) {
    return DotMatrixBase(
      size: size,
      dotSize: dotSize,
      color: color,
      speed: speed,
      semanticsLabel: semanticsLabel,
      pattern: pattern,
      animated: animated,
      hoverAnimated: hoverAnimated,
      opacityBase: opacityBase,
      opacityMid: opacityMid,
      opacityPeak: opacityPeak,
      cellPadding: cellPadding,
      boxSize: boxSize,
      minSize: minSize,
      animationResolver: (ctx) {
        if (!ctx.isActive) return null;
        final path = trBlPathNormFromIndex(ctx.index);
        final slice = ctx.row + (4 - ctx.col);
        final parity = slice % 2;

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return DotAnimationState(opacity: parity == 0 ? 0.88 : 0.14);
        }

        final t = (ctx.cyclePhase + path * 0.2 + parity * 0.5) % 1.0;
        return DotAnimationState(
          opacity: diagonalAltSweepOpacity(t, 0.16, 1.0),
        );
      },
    );
  }
}
