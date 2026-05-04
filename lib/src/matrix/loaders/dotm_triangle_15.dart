import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class TripodHandoffLoader extends StatelessWidget {
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

  const TripodHandoffLoader({
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

  static const double _baseOpacity = 0.08;
  static const double _midOpacity = 0.38;
  static const double _highOpacity = 0.96;

  static const _hubs = [
    (1, 3),
    (4, 0),
    (4, 6),
  ];

  static int _manhattan(int aRow, int aCol, int bRow, int bCol) {
    return (aRow - bRow).abs() + (aCol - bCol).abs();
  }

  static double _smoothstep01(double edge0, double edge1, double x) {
    if (edge1 <= edge0) return x >= edge1 ? 1.0 : 0.0;
    final ct = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return ct * ct * (3 - 2 * ct);
  }

  static double _falloffFromHub(
      int row, int col, (int, int) hub) {
    final d = _manhattan(row, col, hub.$1, hub.$2).toDouble();
    return 1 - _smoothstep01(0, 5.4, d);
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
            ? 0.15
            : ctx.cyclePhase;
        final t = phase * math.pi * 2;
        const sharp = 4.0;
        final u0 = math.pow(math.max(0, math.cos(t)), sharp);
        final u1 = math.pow(
            math.max(0, math.cos(t - (math.pi * 2) / 3)), sharp);
        final u2 = math.pow(
            math.max(0, math.cos(t - (math.pi * 4) / 3)), sharp);
        final sum = u0 + u1 + u2 + 1e-4;

        final glowA = _falloffFromHub(ctx.row, ctx.col, _hubs[0]);
        final glowB = _falloffFromHub(ctx.row, ctx.col, _hubs[1]);
        final glowC = _falloffFromHub(ctx.row, ctx.col, _hubs[2]);
        final glow =
            (glowA * u0 + glowB * u1 + glowC * u2) / sum;

        var opacity =
            _baseOpacity + glow * (_highOpacity - _baseOpacity);

        if (ctx.row == 3 && ctx.col == 3) {
          opacity =
              math.max(opacity, _midOpacity + glow * 0.32);
        }

        return opacity.clamp(0.0, _highOpacity);
      },
    );
  }
}
