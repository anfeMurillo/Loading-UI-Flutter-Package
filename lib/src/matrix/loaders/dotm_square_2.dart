import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../matrix_base.dart';
import '../patterns.dart';

class PulseLadderLoader extends StatefulWidget {
  final double? size;
  final double? dotSize;
  final Color? color;
  final double speed;
  final String? semanticsLabel;
  final MatrixPattern pattern;
  final bool animated;
  final bool hoverAnimated;
  final double? opacityBase;
  final double? opacityMid;
  final double? opacityPeak;
  final double? cellPadding;
  final double? boxSize;
  final double? minSize;

  const PulseLadderLoader({
    super.key,
    this.size,
    this.dotSize,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel = 'Loading',
    this.pattern = MatrixPattern.full,
    this.animated = true,
    this.hoverAnimated = false,
    this.opacityBase,
    this.opacityMid,
    this.opacityPeak,
    this.cellPadding,
    this.boxSize,
    this.minSize,
  });

  @override
  State<PulseLadderLoader> createState() => _PulseLadderLoaderState();
}

class _PulseLadderLoaderState extends State<PulseLadderLoader>
    with SingleTickerProviderStateMixin {
  static const _snakeTail = [1.0, 0.82, 0.68, 0.54, 0.42, 0.31, 0.22, 0.14];
  static const double baseOpacity = 0.08;

  late final List<int> _route;
  late final Map<int, List<int>> _visitsByIndex;

  @override
  void initState() {
    super.initState();
    _route = _buildRoute();
    _visitsByIndex = _buildVisitsMap(_route);
  }

  static List<int> _buildRoute() {
    final path = <int>[];
    void push(int row, int col) => path.add(rowMajorIndex(row, col));

    for (var row = 4; row >= 0; row--) {
      push(row, 0);
    }
    push(0, 1);
    push(0, 2);
    for (var row = 1; row <= 4; row++) {
      push(row, 2);
    }
    push(4, 1);
    for (var row = 3; row >= 0; row--) {
      push(row, 1);
    }
    push(0, 2);
    push(0, 3);
    for (var row = 1; row <= 4; row++) {
      push(row, 3);
    }
    push(4, 2);
    for (var row = 3; row >= 0; row--) {
      push(row, 2);
    }
    push(0, 3);
    push(0, 4);
    for (var row = 1; row <= 4; row++) {
      push(row, 4);
    }
    return path;
  }

  static Map<int, List<int>> _buildVisitsMap(List<int> route) {
    final visits = <int, List<int>>{};
    for (var step = 0; step < route.length; step++) {
      visits.putIfAbsent(route[step], () => []).add(step);
    }
    return visits;
  }

  @override
  Widget build(BuildContext context) {
    return DotMatrixBase(
      size: widget.size,
      dotSize: widget.dotSize,
      color: widget.color,
      speed: widget.speed,
      semanticsLabel: widget.semanticsLabel,
      pattern: widget.pattern,
      animated: widget.animated,
      hoverAnimated: widget.hoverAnimated,
      opacityBase: widget.opacityBase,
      opacityMid: widget.opacityMid,
      opacityPeak: widget.opacityPeak,
      cellPadding: widget.cellPadding,
      boxSize: widget.boxSize,
      minSize: widget.minSize,
      animationResolver: (ctx) {
        if (!ctx.isActive) return null;

        final routeLen = _route.length;
        if (routeLen <= 0) {
          return DotAnimationState(opacity: baseOpacity);
        }

        final head = (ctx.cyclePhase * routeLen).floor() % routeLen;
        final visits = _visitsByIndex[ctx.index] ?? [];
        var opacity = baseOpacity;
        for (final stepIndex in visits) {
          final distance = (head - stepIndex + routeLen) % routeLen;
          if (distance >= 0 && distance < _snakeTail.length) {
            opacity = math.max(opacity, _snakeTail[distance]);
          }
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
