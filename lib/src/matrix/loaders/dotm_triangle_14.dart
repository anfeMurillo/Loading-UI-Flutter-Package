import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class PillarSweepLoader extends StatelessWidget {
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

  const PillarSweepLoader({
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

  static const double _baseOpacity = 0.07;
  static const double _midOpacity = 0.32;
  static const double _highOpacity = 0.96;

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
        final beamCenter = phase * 7.2 - 0.35;
        final dist = (ctx.col - beamCenter).abs();
        final core = 1 - _smoothstep01(0, 0.62, dist);
        final halo = 1 - _smoothstep01(0.35, 1.42, dist);
        final eased = core * 0.92 + halo * 0.22;
        var opacity =
            _baseOpacity + eased * (_highOpacity - _baseOpacity);

        if (ctx.row == 3 && ctx.col == 3) {
          opacity = math.max(opacity, _midOpacity + eased * 0.28);
        }

        return opacity.clamp(0.0, _highOpacity);
      },
    );
  }
}
