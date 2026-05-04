import 'package:flutter/material.dart';

import '../matrix_base.dart';
import '../patterns.dart';

class MobiusRunLoader extends StatelessWidget {
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

  const MobiusRunLoader({
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

  static const _perimeterPath = [
    0, 1, 2, 3, 4,  // (0,0)-(0,4)
    9, 14, 19, 24,   // (1,4)-(4,4)
    23, 22, 21, 20,  // (4,3)-(4,0)
    15, 10, 5,        // (3,0)-(1,0)
  ];

  static const int _loopLen = 16;
  static const List<double> _tailBright = [1, 0.82, 0.64, 0.46, 0.3, 0.18];
  static const List<double> _backTailBright = [0.38, 0.3, 0.22, 0.14];
  static const double _baseOpacity = 0.08;
  static const double _twistInnerOpacity = 0.52;
  static const double _seamPulseOpacity = 0.55;
  static const double _idleRingOpacity = 0.48;

  static final _twistInnerByHeadStep = {
    0: rowMajorIndex(1, 1),
    4: rowMajorIndex(1, 3),
    8: rowMajorIndex(3, 3),
    12: rowMajorIndex(3, 1),
  };

  static int _pathStepForCellIndex(int cellIndex) {
    return _perimeterPath.indexOf(cellIndex);
  }

  static double _opacityFromTail(int distance, List<double> tail) {
    if (distance < 0 || distance >= tail.length) return 0;
    return tail[distance];
  }

  @override
  Widget build(BuildContext context) {
    return DotMatrixBase(
      size: size,
      dotSize: dotSize,
      color: color,
      speed: speed,
      semanticsLabel: semanticsLabel,
      pattern: pattern,
      animated: animated,
      hoverAnimated: hoverAnimated,
      opacityBase: opacityBase,
      opacityMid: opacityMid,
      opacityPeak: opacityPeak,
      cellPadding: cellPadding,
      boxSize: boxSize,
      minSize: minSize,
      animationResolver: (ctx) {
        if (!ctx.isActive) return null;

        final onLoop = _pathStepForCellIndex(ctx.index);
        final headStep =
            (ctx.cyclePhase * _loopLen).floor() % _loopLen;
        final backHead =
            (headStep + _loopLen ~/ 2) % _loopLen;

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          if (onLoop >= 0) {
            return const DotAnimationState(opacity: _idleRingOpacity);
          }
          if (ctx.index == rowMajorIndex(2, 2)) {
            return const DotAnimationState(opacity: 0.22);
          }
          return const DotAnimationState(opacity: _baseOpacity);
        }

        var opacity = _baseOpacity;

        if (onLoop >= 0) {
          final forward = (headStep - onLoop + _loopLen) % _loopLen;
          final alongBack =
              (backHead - onLoop + _loopLen) % _loopLen;
          opacity = [
            opacity,
            _opacityFromTail(forward, _tailBright),
            _opacityFromTail(alongBack, _backTailBright),
          ].reduce((a, b) => a > b ? a : b);
        }

        final twistInner = _twistInnerByHeadStep[headStep];
        if (twistInner == ctx.index) {
          opacity = opacity > _twistInnerOpacity
              ? opacity
              : _twistInnerOpacity;
        }

        final seam = rowMajorIndex(2, 2);
        if (ctx.index == seam && headStep % 4 == 0) {
          opacity = opacity > _seamPulseOpacity
              ? opacity
              : _seamPulseOpacity;
        }

        return DotAnimationState(opacity: opacity < 1 ? opacity : 1.0);
      },
    );
  }
}
