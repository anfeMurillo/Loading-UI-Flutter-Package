import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class AltitudeWaveLoader extends StatelessWidget {
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

  const AltitudeWaveLoader({
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
  static const double _baseOpacity = 0.08;
  static const double _midOpacity = 0.34;
  static const double _highOpacity = 0.94;

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
        final progress = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0.0
            : (ctx.cyclePhase * _stepCount).floor() / _stepCount;

        final rowPhase = (4 - ctx.row) * 0.13;
        final pulse =
            0.5 - 0.5 * math.cos((progress + rowPhase) * math.pi * 2);
        final crest = pulse * pulse;
        final altitudeWeight = 0.58 + (4 - ctx.row) * 0.16;
        final centerWeight = ctx.col == 3 ? 0.16 : 0.0;

        final opacity = _baseOpacity +
            pulse * (_midOpacity - _baseOpacity) +
            crest *
                (altitudeWeight + centerWeight) *
                (_highOpacity - _midOpacity);

        return opacity.clamp(0.0, _highOpacity);
      },
    );
  }
}
