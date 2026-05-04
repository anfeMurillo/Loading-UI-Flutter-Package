import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class ObliqueWeaveLoader extends StatelessWidget {
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

  const ObliqueWeaveLoader({
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
  static const double _midOpacity = 0.38;
  static const double _highOpacity = 0.96;

  static double _opacityForCell(int row, int col, double phase) {
    final diag = row + col;
    final t = phase * math.pi * 2;
    final u = diag * 0.55 - t * 1.35;
    final primary = 0.5 + 0.5 * math.cos(u);
    final harmonic = 0.5 + 0.5 * math.cos(u * 2 + 0.4);
    final crest = primary * primary * 0.92 +
        ((harmonic - 0.35) > 0 ? harmonic - 0.35 : 0.0) * 0.28;
    var opacity =
        _baseOpacity + crest * (_highOpacity - _baseOpacity);

    if (row == 3 && col == 3) {
      opacity =
          math.max(opacity, _midOpacity + (crest - 0.25) * 0.35);
    }

    return opacity < _highOpacity ? opacity : _highOpacity;
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

        final phase = ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0.22
            : ctx.cyclePhase;
        return _opacityForCell(ctx.row, ctx.col, phase);
      },
    );
  }
}
