import 'package:flutter/material.dart';

import '../triangle_base.dart';

class InfinityTraceLoader extends StatelessWidget {
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

  const InfinityTraceLoader({
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
  static const double _highOpacity = 0.95;

  static const _infinityPath = [
    (4, 0),
    (3, 1),
    (2, 2),
    (1, 3),
    (2, 4),
    (3, 5),
    (4, 6),
    (4, 4),
    (3, 3),
    (4, 2),
  ];

  static final int _pathLen = _infinityPath.length;
  static const double _trailSpan = 4.35;

  static int? _pathIndex(int row, int col) {
    for (var i = 0; i < _pathLen; i++) {
      final (pr, pc) = _infinityPath[i];
      if (pr == row && pc == col) return i;
    }
    return null;
  }

  static int _mod(int n, int m) => ((n % m) + m) % m;

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
        final idx = _pathIndex(ctx.row, ctx.col);
        if (idx == null) return 0.0;

        final s = phase * _pathLen;
        final d = _mod(s.round() - idx, _pathLen).toDouble();
        final g = 1 - _smoothstep01(0, _trailSpan, d);
        return _baseOpacity + g * (_highOpacity - _baseOpacity);
      },
    );
  }
}
