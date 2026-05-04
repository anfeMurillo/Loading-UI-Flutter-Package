import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class CoronaTierLoader extends StatelessWidget {
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

  const CoronaTierLoader({
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

  static const double _baseOpacity = 0.14;
  static const double _highOpacity = 0.96;

  static const _triangleCells = {
    (1, 3),
    (2, 2),
    (2, 4),
    (3, 1),
    (3, 3),
    (3, 5),
    (4, 0),
    (4, 2),
    (4, 4),
    (4, 6),
  };

  static const _deltas8 = [
    (-1, -1),
    (-1, 0),
    (-1, 1),
    (0, -1),
    (0, 1),
    (1, -1),
    (1, 0),
    (1, 1),
  ];

  static final Map<(int, int), int> _bfsRing = _buildBfsRing();
  static final int _maxRing = _bfsRing.values.fold(0, math.max);

  static Map<(int, int), int> _buildBfsRing() {
    final dist = <(int, int), int>{};
    dist[(3, 3)] = 0;
    final queue = <(int, int)>[(3, 3)];
    var head = 0;
    while (head < queue.length) {
      final (r, c) = queue[head++];
      final d = dist[(r, c)]!;
      for (final (dr, dc) in _deltas8) {
        final nr = r + dr;
        final nc = c + dc;
        if (_triangleCells.contains((nr, nc)) &&
            !dist.containsKey((nr, nc))) {
          dist[(nr, nc)] = d + 1;
          queue.add((nr, nc));
        }
      }
    }
    return dist;
  }

  static double _smoothstep01(double edge0, double edge1, double x) {
    if (edge1 <= edge0) return x >= edge1 ? 1.0 : 0.0;
    final t = (x - edge0) / (edge1 - edge0);
    final ct = t.clamp(0.0, 1.0);
    return ct * ct * (3 - 2 * ct);
  }

  @override
  Widget build(BuildContext context) {
    final span = _maxRing.toDouble();

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
        final ring = _bfsRing[(ctx.row, ctx.col)] ?? 0;
        final t = phase * math.pi * 2;
        final u = (ring / span) * math.pi * 2 - t;
        final wave = 0.5 + 0.5 * math.cos(u);
        final crest = _smoothstep01(0.35, 1.0, wave);
        return (_baseOpacity + crest * (_highOpacity - _baseOpacity))
            .clamp(0.0, _highOpacity);
      },
    );
  }
}
