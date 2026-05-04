import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class ShelfDescentLoader extends StatelessWidget {
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

  const ShelfDescentLoader({
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

  static const double _baseOpacity = 0.13;
  static const double _midOpacity = 0.36;
  static const double _highOpacity = 0.96;

  static const _apexRow = 1;
  static const _apexCol = 3;

  static int _manhattanFromApex(int row, int col) {
    return (row - _apexRow).abs() + (col - _apexCol).abs();
  }

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
            ? 0.18
            : ctx.cyclePhase;
        final tier = _manhattanFromApex(ctx.row, ctx.col);
        const maxTier = 6;
        final t = phase * math.pi * 2;
        final u = (tier / maxTier) * math.pi * 2 - t;
        final wave = 0.5 + 0.5 * math.cos(u);
        final crest = _smoothstep01(0.28, 0.98, wave);
        var opacity =
            _baseOpacity + crest * (_highOpacity - _baseOpacity);

        if (ctx.row == 3 && ctx.col == 3) {
          opacity = math.max(opacity, _midOpacity + crest * 0.35);
        }

        return opacity.clamp(0.0, _highOpacity);
      },
    );
  }
}
