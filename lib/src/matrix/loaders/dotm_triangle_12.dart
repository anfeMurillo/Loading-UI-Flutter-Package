import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class SkewDriftLoader extends StatelessWidget {
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

  const SkewDriftLoader({
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

  static const double _baseOpacity = 0.06;
  static const double _midOpacity = 0.34;
  static const double _highOpacity = 0.96;

  static double _smoothstep01(double edge0, double edge1, double x) {
    if (edge1 <= edge0) return x >= edge1 ? 1.0 : 0.0;
    final t = (x - edge0) / (edge1 - edge0);
    final ct = t.clamp(0.0, 1.0);
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
            ? 0.2
            : ctx.cyclePhase;
        final skew = ctx.row - ctx.col;
        final t = phase * math.pi * 2;
        final u = skew * 0.62 - t * 1.45;
        final primary = 0.5 + 0.5 * math.cos(u);
        final harmonic = 0.5 + 0.5 * math.cos(u * 2 - 0.55);
        final pSoft = _smoothstep01(0.12, 0.95, primary);
        final hSoft = _smoothstep01(0.38, 0.92, harmonic);
        final crest = pSoft * pSoft * 0.88 +
            (hSoft - 0.42).clamp(0.0, 1.0) * 0.32;
        var opacity =
            _baseOpacity + crest * (_highOpacity - _baseOpacity);

        if (ctx.row == 3 && ctx.col == 3) {
          opacity =
              math.max(opacity, _midOpacity + (crest - 0.22) * 0.4);
        }

        return opacity.clamp(0.0, _highOpacity);
      },
    );
  }
}
