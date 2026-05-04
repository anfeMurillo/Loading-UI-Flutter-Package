import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../matrix_base.dart';

class HalfHelixLoader extends StatelessWidget {
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

  const HalfHelixLoader({
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

  static const double _baseOpacity = 0.08;
  static const double _strandOpacity = 1.0;
  static const double _nearStrandOpacity = 0.24;
  static const double _stepCount = 20.0;
  static const double _helixLoopRadians = math.pi * 2 / (_stepCount - 1);

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

        final t = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : ctx.cyclePhase * _stepCount;
        final rowPhase = t * _helixLoopRadians + ctx.row * 1.24;
        final strandCol = (2 + 2 * math.sin(rowPhase)).round();

        if (ctx.col == strandCol) {
          return const DotAnimationState(opacity: _strandOpacity);
        }

        if ((ctx.col - strandCol).abs() == 1) {
          return const DotAnimationState(opacity: _nearStrandOpacity);
        }

        return const DotAnimationState(opacity: _baseOpacity);
      },
    );
  }
}
