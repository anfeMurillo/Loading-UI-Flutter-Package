import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class VertexChaseLoader extends StatelessWidget {
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

  const VertexChaseLoader({
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

  static const int _stepCount = 28;
  static const double _baseOpacity = 0.0;
  static const double _midOpacity = 0.0;
  static const List<double> _trailLevels = [0.96, 0.52, 0.3];

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

  @override
  Widget build(BuildContext context) {
    final pathLen = _perimeterPath.length;
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

        var opacity = ctx.row == 3 && ctx.col == 3
            ? _midOpacity
            : _baseOpacity;

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return opacity;
        }

        final segmentLength =
            (_stepCount / 3).floor().clamp(1, _stepCount);
        final frame =
            (ctx.cyclePhase * _stepCount).floor() % _stepCount;

        for (var headOffset = 0; headOffset < 3; headOffset++) {
          final spokeFrame =
              (frame + headOffset * segmentLength) % _stepCount;
          final head =
              ((spokeFrame / _stepCount) * pathLen).floor() % pathLen;

          for (var trail = 0; trail < _trailLevels.length; trail++) {
            final idx =
                (head - trail + pathLen) % pathLen;
            final (pathRow, pathCol) = _perimeterPath[idx];
            if (ctx.row == pathRow && ctx.col == pathCol) {
              opacity =
                  math.max(opacity, _trailLevels[trail]);
              break;
            }
          }
        }

        return opacity;
      },
    );
  }
}
