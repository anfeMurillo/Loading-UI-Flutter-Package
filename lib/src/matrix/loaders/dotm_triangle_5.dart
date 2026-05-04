import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class RowSweepLoader extends StatelessWidget {
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

  const RowSweepLoader({
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

  static const int _stepCount = 42;
  static const double _baseOpacity = 0.06;
  static const double _midOpacity = 0.3;
  static const double _highOpacity = 0.92;

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
        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return _baseOpacity +
              (4 - ctx.row) / 3.clamp(1, 3) * (_midOpacity - _baseOpacity);
        }

        final progress =
            (ctx.cyclePhase * _stepCount).floor() / _stepCount;
        final pingPong = 0.5 -
            0.5 * math.cos(progress * math.pi * 2);
        final scanRow = 1 + pingPong * 3;

        final distance = (ctx.row - scanRow).abs();
        final beam = math.max(0.0, 1 - distance / 2.2);
        final easedBeam = beam * beam;
        var opacity =
            _baseOpacity + easedBeam * (_highOpacity - _baseOpacity);

        if (distance > 1.3) {
          opacity = math.max(
              opacity,
              _midOpacity -
                  (distance - 1.3).clamp(0.0, 1.5) * 0.12);
        }

        if (ctx.row == 3 && ctx.col == 3) {
          opacity = math.max(opacity, 0.42);
        }

        return opacity;
      },
    );
  }
}
