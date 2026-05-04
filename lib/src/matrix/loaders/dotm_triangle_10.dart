import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../triangle_base.dart';

class ColumnRakeLoader extends StatelessWidget {
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

  const ColumnRakeLoader({
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

  static const int _stepCount = 36;
  static const double _baseOpacity = 0.07;
  static const List<double> _tailLevels = [0.94, 0.68, 0.42, 0.24];

  static const _columnRakePath = [
    (4, 0),
    (3, 1),
    (4, 2),
    (2, 2),
    (3, 3),
    (1, 3),
    (4, 4),
    (2, 4),
    (4, 6),
    (3, 5),
  ];

  @override
  Widget build(BuildContext context) {
    final pathLen = _columnRakePath.length;
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
        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return _baseOpacity;
        }

        var opacity = _baseOpacity;
        final head =
            ((ctx.cyclePhase * _stepCount).floor() / _stepCount * pathLen)
                    .floor() %
                pathLen;

        for (var trail = 0; trail < _tailLevels.length; trail++) {
          final idx = (head - trail + pathLen) % pathLen;
          final (pathRow, pathCol) = _columnRakePath[idx];
          if (ctx.row == pathRow && ctx.col == pathCol) {
            opacity = math.max(opacity, _tailLevels[trail]);
            break;
          }
        }

        return opacity;
      },
    );
  }
}
