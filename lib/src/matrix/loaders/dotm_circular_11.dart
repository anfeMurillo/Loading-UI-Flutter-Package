import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class LunarBreatheLoader extends StatelessWidget {
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

  const LunarBreatheLoader({
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
  static const double _midOpacity = 0.3;
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

        final x = ctx.col - 2.0;
        final y = ctx.row - 2.0;
        final ring = math.sqrt(x * x + y * y);
        final t = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : ctx.cyclePhase * math.pi * 2;
        final angle = math.atan2(y, x);
        final moonCenterX = math.cos(t) * 0.7;
        final moonCenterY = math.sin(t) * 0.7;
        final body = math.sqrt(
          (x - moonCenterX) * (x - moonCenterX) +
              (y - moonCenterY) * (y - moonCenterY),
        );
        final cutCenterX = moonCenterX + math.cos(t) * 0.82;
        final cutCenterY = moonCenterY + math.sin(t) * 0.82;
        final cut = math.sqrt(
          (x - cutCenterX) * (x - cutCenterX) +
              (y - cutCenterY) * (y - cutCenterY),
        );
        final rim =
            (1 - (body - 1.55).abs() / 0.35).clamp(0.0, 1.0);
        final halo = (1 - math.acos(math.cos(angle - t)) / 0.9)
            .clamp(0.0, 1.0);

        var opacity = _baseOpacity;
        if (body < 1.55 && cut > 1.05) {
          opacity = _highOpacity;
        } else if (rim > 0.5) {
          opacity = _midOpacity + rim * 0.22;
        } else if (halo > 0.68 && ring > 1.2) {
          opacity = _midOpacity;
        }

        return DotAnimationState(
          opacity: opacity.clamp(0.0, _highOpacity),
        );
      },
    );
  }
}
