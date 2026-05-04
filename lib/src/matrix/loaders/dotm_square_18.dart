import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../matrix_base.dart';

class SoundBarsLoader extends StatelessWidget {
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

  const SoundBarsLoader({
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
  static const double _litOpacity = 0.94;
  static const double _capOpacity = 1.0;
  static const int _stepCount = 24;
  static const int _maxLevel = 5;

  static int _clampLevel(double value) =>
      value.round().clamp(1, _maxLevel);

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

        // cycleMsBase=1750 in React; we use the base controller's cycle
        final scaledT = ctx.cyclePhase * _stepCount;
        final colPhase = scaledT * 0.52 + ctx.col * 1.15;
        final level = _clampLevel(
            1 + ((math.sin(colPhase) + 1) / 2) * (_maxLevel - 1));
        final topLitRow = _maxLevel - level;

        if (ctx.row > topLitRow) {
          return DotAnimationState(opacity: _litOpacity);
        }
        if (ctx.row == topLitRow) {
          return DotAnimationState(opacity: _capOpacity);
        }
        return DotAnimationState(opacity: _baseOpacity);
      },
    );
  }
}
