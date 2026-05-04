import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class HollowShellLoader extends StatelessWidget {
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

  const HollowShellLoader({
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

  static const double _coreDim = 0.1;
  static const double _shellLow = 0.22;
  static const double _shellHigh = 0.96;

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

        if (ctx.row == 3 && ctx.col == 3) {
          return _coreDim;
        }

        final phase = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.2
            : ctx.cyclePhase;
        final breathe = 0.5 + 0.5 * math.sin(phase * math.pi * 2);
        final crest = _smoothstep01(0.2, 0.94, breathe);
        return _shellLow + crest * (_shellHigh - _shellLow);
      },
    );
  }
}
