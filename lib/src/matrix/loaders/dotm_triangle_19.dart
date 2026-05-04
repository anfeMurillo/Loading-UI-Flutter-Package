import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class PivotRayLoader extends StatelessWidget {
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

  const PivotRayLoader({
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
  static const double _beamSigma = 0.58;

  static double _angleDiff(double a, double b) {
    var d = a - b;
    while (d > math.pi) {
      d -= math.pi * 2;
    }
    while (d < -math.pi) {
      d += math.pi * 2;
    }
    return d;
  }

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

        const centerRow = 3;
        const centerCol = 3;

        final phase = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.12
            : ctx.cyclePhase;

        if (ctx.row == centerRow && ctx.col == centerCol) {
          final hub = 0.5 + 0.5 * math.sin(phase * math.pi * 2);
          final hubSoft = _smoothstep01(0.12, 0.9, hub);
          return _midOpacity + hubSoft * 0.22;
        }

        final t = phase * math.pi * 2;
        final ang = math.atan2(
            (ctx.row - centerRow).toDouble(),
            (ctx.col - centerCol).toDouble());
        final d = _angleDiff(ang, t);
        final beamRaw = math.exp(
            -(d * d) / (_beamSigma * _beamSigma));
        final beam = _smoothstep01(0.05, 0.98, beamRaw);
        final rim =
            0.5 + 0.5 * math.cos(ang * 2 - t * 1.15);
        final accent = _smoothstep01(0.45, 0.92, rim) * 0.18;
        return (_baseOpacity +
                (beam + accent) * (_highOpacity - _baseOpacity))
            .clamp(0.0, _highOpacity);
      },
    );
  }
}
