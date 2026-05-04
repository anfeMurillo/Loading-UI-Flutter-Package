import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../matrix_base.dart';

class InfinityRunLoader extends StatelessWidget {
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

  const InfinityRunLoader({
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

  static const int _stepCount = 48;
  static const double _baseOpacity = 0.08;
  static const double _secondaryTrailOpacity = 0.32;
  static const double _primaryTrailOpacity = 0.62;
  static const double _peakOpacity = 1.0;
  static const double _curveOpacity = 0.2;

  static (double, double) _gridPoint(int row, int col) {
    return ((col - 2) / 2, (2 - row) / 2);
  }

  static (double, double) _loopPoint(int step) {
    final t = ((step % _stepCount) / _stepCount) * math.pi * 2;
    return (math.sin(t), 0.58 * math.sin(2 * t));
  }

  static double _squaredDistance(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return dx * dx + dy * dy;
  }

  static double _headInfluence(double dx, double dy, double hx, double hy) {
    final distSq = _squaredDistance(dx, dy, hx, hy);
    return math.exp(-distSq / 0.19);
  }

  static double _minCurveDistanceSq(double x, double y) {
    var min = double.infinity;
    for (var i = 0; i < 96; i++) {
      final t = (i / 96) * math.pi * 2;
      final cx = math.sin(t);
      final cy = 0.58 * math.sin(2 * t);
      final d = _squaredDistance(x, y, cx, cy);
      if (d < min) min = d;
    }
    return min;
  }

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

        final (dx, dy) = _gridPoint(ctx.row, ctx.col);

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          final curveGlow =
              math.exp(-_minCurveDistanceSq(dx, dy) / 0.2);
          final centerBoost =
              math.exp(-(dx * dx + dy * dy) / 0.06);
          return DotAnimationState(
              opacity: (math.min(_peakOpacity,
                      _baseOpacity +
                          curveGlow * _curveOpacity +
                          centerBoost * 0.18))
                  .toDouble());
        }

        final step =
            (ctx.cyclePhase * _stepCount).floor() % _stepCount;
        final (hax, hay) = _loopPoint(step);
        final (hbx, hby) = _loopPoint(step + _stepCount ~/ 2);
        final (tax, tay) = _loopPoint(step - 4);
        final (tbx, tby) = _loopPoint(step + _stepCount ~/ 2 - 4);

        final lead = math.max(
            _headInfluence(dx, dy, hax, hay),
            _headInfluence(dx, dy, hbx, hby));
        final trail = math.max(
            _headInfluence(dx, dy, tax, tay),
            _headInfluence(dx, dy, tbx, tby));
        final centerPulse = math.exp(-(dx * dx + dy * dy) / 0.05) *
            (0.45 + 0.55 * lead);

        final opacity = _baseOpacity +
            _secondaryTrailOpacity * trail +
            _primaryTrailOpacity * lead +
            0.16 * centerPulse;

        return DotAnimationState(
            opacity: math.min(_peakOpacity, opacity));
      },
    );
  }
}
