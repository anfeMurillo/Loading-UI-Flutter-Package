import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class UpdraftLoader extends StatelessWidget {
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

  const UpdraftLoader({
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

  static const double _baseOpacity = 0.1;
  static const double _midOpacity = 0.36;
  static const double _highOpacity = 0.96;
  static const double _wing = 0.52;
  static const double _frontSigma = 0.88;

  static double _smoothstep01(double edge0, double edge1, double x) {
    if (edge1 <= edge0) return x >= edge1 ? 1.0 : 0.0;
    final ct = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return ct * ct * (3 - 2 * ct);
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
            ? 0.12
            : ctx.cyclePhase;
        final t = phase * math.pi * 2;
        final v = ctx.row - _wing * (ctx.col - 3).abs();
        final front = 1.85 + 1.4 * math.sin(t);
        final d = (v - front).abs();
        final glowRaw = math.exp(
            -(d * d) / (_frontSigma * _frontSigma));
        final glow = _smoothstep01(0.04, 0.98, glowRaw);
        var opacity =
            _baseOpacity + glow * (_highOpacity - _baseOpacity);

        if (ctx.row == 3 && ctx.col == 3) {
          opacity = math.max(
              opacity,
              _midOpacity * 0.58 +
                  glow *
                      (_highOpacity - _midOpacity) *
                      0.48);
        }

        return opacity.clamp(0.0, _highOpacity);
      },
    );
  }
}
