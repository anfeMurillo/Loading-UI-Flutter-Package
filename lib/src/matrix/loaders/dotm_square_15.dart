import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../matrix_base.dart';

class HelixGlowLoader extends StatelessWidget {
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

  const HelixGlowLoader({
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
  static const double _bridgeOpacity = 0.58;
  static const double _nearStrandOpacity = 0.24;
  static const double _strandLoops = 2.0;

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

        final u = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : ctx.cyclePhase;
        final rowPhase = u * _strandLoops * 2 * math.pi + ctx.row * 1.24;
        final left = (1 + math.sin(rowPhase)).round();
        final right = 4 - left;
        final bridgeOn = math.cos(rowPhase * 2) > 0.82;

        if (ctx.col == left || ctx.col == right) {
          return const DotAnimationState(opacity: _strandOpacity);
        }

        if (bridgeOn && ctx.col > left && ctx.col < right) {
          return const DotAnimationState(opacity: _bridgeOpacity);
        }

        if ((ctx.col - left).abs() == 1 || (ctx.col - right).abs() == 1) {
          return const DotAnimationState(opacity: _nearStrandOpacity);
        }

        return const DotAnimationState(opacity: _baseOpacity);
      },
    );
  }
}
