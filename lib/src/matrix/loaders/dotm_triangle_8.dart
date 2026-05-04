import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class WingMetronomeLoader extends StatelessWidget {
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

  const WingMetronomeLoader({
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

  static const double _baseOpacity = 0.05;
  static const double _midOpacity = 0.42;
  static const double _highOpacity = 0.96;

  static const _leftWing = {(2, 2), (3, 1), (4, 0), (4, 2)};
  static const _rightWing = {(2, 4), (3, 5), (4, 4), (4, 6)};

  static String _sectorForCell(int row, int col) {
    if (row == 1 && col == 3) return 'spine';
    if (row == 3 && col == 3) return 'spine';
    if (_leftWing.contains((row, col))) return 'left';
    if (_rightWing.contains((row, col))) return 'right';
    return 'none';
  }

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
        if (!ctx.isActive) return 0.0;

        final phase = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.25
            : ctx.cyclePhase;
        final p = 0.5 - 0.5 * math.cos(phase * math.pi * 2);
        final leftLift = p * p;
        final rightLift = (1 - p) * (1 - p);
        final crossover =
            (1 - 4 * (p - 0.5) * (p - 0.5)).clamp(0.0, 1.0);

        final sector = _sectorForCell(ctx.row, ctx.col);
        if (sector == 'none') return 0.0;

        if (sector == 'spine') {
          if (ctx.row == 1 && ctx.col == 3) {
            return (_midOpacity +
                    crossover *
                        (_highOpacity - _midOpacity) *
                        0.95)
                .clamp(0.0, _highOpacity);
          }
          return (_baseOpacity +
                  crossover * 0.55 * (_highOpacity - _baseOpacity) +
                  leftLift * 0.08 +
                  rightLift * 0.08)
              .clamp(0.0, _highOpacity);
        }

        if (sector == 'left') {
          return (_baseOpacity +
                  leftLift * (_highOpacity - _baseOpacity))
              .clamp(0.0, _highOpacity);
        }

        return (_baseOpacity +
                rightLift * (_highOpacity - _baseOpacity))
            .clamp(0.0, _highOpacity);
      },
    );
  }
}
