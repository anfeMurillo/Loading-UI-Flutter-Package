import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../matrix_base.dart';

class CrtGlideLoader extends StatelessWidget {
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

  const CrtGlideLoader({
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

        const rows = 5;
        const baseOpacity = 0.08;
        const peakOpacity = 1.0;
        const decay = 0.72;
        const colWarp = 0.07;

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          final falloff = (rows - 1 - ctx.row) / (rows - 1).clamp(1, 4).toDouble();
          return DotAnimationState(opacity: baseOpacity + falloff * 0.38);
        }

        final scanRow = (ctx.cyclePhase * rows).floor() % rows;
        final colGain = 1 + colWarp * math.sin(ctx.col * 1.72 + scanRow * 0.61);

        if (ctx.row > scanRow) {
          return DotAnimationState(opacity: baseOpacity);
        }

        final age = scanRow - ctx.row;
        final trail = math.exp(-age * decay);
        final opacity =
            baseOpacity + (peakOpacity - baseOpacity) * trail * colGain;

        return DotAnimationState(opacity: opacity.clamp(0.0, peakOpacity));
      },
    );
  }
}
