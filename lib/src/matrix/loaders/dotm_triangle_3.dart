import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class CornerBounceLoader extends StatelessWidget {
  final double size;
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

  const CornerBounceLoader({
    super.key,
    this.size = 30.0,
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
  });

  static const int _stepCount = 36;
  static const double _baseOpacity = 0.03;
  static const double _midOpacity = 0.07;
  static const double _highOpacity = 0.94;
  static const double _farOpacity = 0.15;

  @override
  Widget build(BuildContext context) {
    return TriangleMatrixBase(
      size: size,
      dotSize: dotSize,
      color: color,
      speed: speed,
      semanticsLabel: semanticsLabel,
      animated: animated,
      hoverAnimated: hoverAnimated,
      opacityBase: opacityBase,
      opacityMid: opacityMid,
      opacityPeak: opacityPeak,
      cellPadding: cellPadding,
      opacityResolver: (ctx) {
        final frame = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : (ctx.cyclePhase * _stepCount).floor().toDouble();
        final theta = (frame / _stepCount) * math.pi * 2;
        final sweepX = math.cos(theta);
        final sweepY = math.sin(theta);
        final ambientPulse = 0.5 - 0.5 * math.cos(theta);

        final centerRow = ctx.row - 3;
        final centerCol = ctx.col - 3;
        final radius = math.sqrt(
            (centerRow * centerRow) + (centerCol * centerCol));
        final projection = centerCol * sweepX + centerRow * sweepY;
        final perpendicular =
            (centerCol * sweepY - centerRow * sweepX).abs();
        final ahead = math.max(0.0, projection);
        final beamCore = math.max(0.0, 1 - perpendicular / 0.45);
        final beamHalo = math.max(0.0, 1 - perpendicular / 1.15);
        final rangeFade = math.max(0.25, 1 - radius / 3.6);
        final trail = beamHalo * math.max(0.0, 1 - ahead / 3.6);

        var opacity = _baseOpacity +
            ambientPulse *
                (_midOpacity - _baseOpacity) *
                rangeFade;

        opacity = math.max(
            opacity,
            _midOpacity +
                beamCore * (_highOpacity - _midOpacity));
        opacity = math.max(
            opacity,
            _farOpacity +
                trail * (_midOpacity - _farOpacity));

        if (ctx.row == 3 && ctx.col == 3) {
          opacity = math.max(opacity, 0.56);
        }

        return opacity.clamp(0.0, _highOpacity);
      },
    );
  }
}
