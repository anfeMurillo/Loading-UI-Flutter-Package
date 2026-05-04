import 'package:flutter/material.dart';

import '../triangle_base.dart';

class TwinPerimeterLoader extends StatelessWidget {
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

  const TwinPerimeterLoader({
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
  static const double _highOpacity = 0.94;
  static const double _centerDim = 0.2;

  static const _perimeterPath = [
    (1, 3),
    (2, 2),
    (3, 1),
    (4, 0),
    (4, 2),
    (4, 4),
    (4, 6),
    (3, 5),
    (2, 4),
  ];

  static final int _pathLen = _perimeterPath.length;
  static const double _trailSpan = 3.35;
  static final double _half = _pathLen / 2.0;

  static int _mod(int n, int m) => ((n % m) + m) % m;

  static int _behindAlongPath(double s, int i, int l) {
    return _mod(s.round() - i, l);
  }

  static double _smoothstep01(double edge0, double edge1, double x) {
    if (edge1 <= edge0) return x >= edge1 ? 1.0 : 0.0;
    final ct = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return ct * ct * (3 - 2 * ct);
  }

  static double _glowAlongPath(double s, int? idx, int l) {
    if (idx == null) return _baseOpacity;
    final d = _behindAlongPath(s, idx, l).toDouble();
    final g = 1 - _smoothstep01(0, _trailSpan, d);
    return _baseOpacity + g * (_highOpacity - _baseOpacity);
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
          return _centerDim;
        }

        final phase = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0.1
            : ctx.cyclePhase;

        int? idx;
        for (var i = 0; i < _pathLen; i++) {
          final (pr, pc) = _perimeterPath[i];
          if (pr == ctx.row && pc == ctx.col) {
            idx = i;
            break;
          }
        }

        final s1 = phase * _pathLen;
        final s2 = _mod(s1.round() + _half.round(), _pathLen);
        final a = _glowAlongPath(s1, idx, _pathLen);
        final b = _glowAlongPath(s2.toDouble(), idx, _pathLen);
        return a > b ? a : b;
      },
    );
  }
}
