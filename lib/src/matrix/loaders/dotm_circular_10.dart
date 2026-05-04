import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class BinaryBloomLoader extends StatelessWidget {
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

  const BinaryBloomLoader({
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

  static const double _baseOpacity = 0.06;
  static const double _lowOpacity = 0.2;
  static const double _midOpacity = 0.48;
  static const double _highOpacity = 0.94;

  static double _moduloDistance(num a, num b, int mod) {
    final raw = (a - b).abs().toDouble();
    return raw < (mod - raw) ? raw : (mod - raw).toDouble();
  }

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

        final x = ctx.col - 2;
        final y = ctx.row - 2;
        final ring = math
            .sqrt((x * x + y * y).toDouble())
            .round();
        final tick = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0
            : (ctx.cyclePhase * 10).floor();
        final cellCode =
            (ctx.row * 3 + ctx.col * 5 + ring * 2) % 10;
        final d = _moduloDistance(cellCode, tick, 10);
        final parityGate = (ctx.row + ctx.col + tick) % 2 == 0;

        var opacity = _baseOpacity;
        if (d == 0) {
          opacity = _highOpacity;
        } else if (d == 1) {
          opacity = _midOpacity;
        } else if (d == 2 || parityGate) {
          opacity = _lowOpacity;
        }

        if (x == 0 && y == 0) {
          opacity = opacity > _midOpacity ? opacity : _midOpacity;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
