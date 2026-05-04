import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class PlasmaVeilLoader extends StatelessWidget {
  final double? size;
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
  final double? boxSize;
  final double? minSize;

  const PlasmaVeilLoader({
    super.key,
    this.size,
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
    this.boxSize,
    this.minSize,
  });

  static const int _stepCount = 24;
  static const double _baseOpacity = 0.08;
  static const double _ringBaseOpacity = 0.2;
  static const double _coreOpacity = 0.16;
  static const List<double> _cometTail = [1.0, 0.78, 0.56, 0.36, 0.22];
  static const double _secondaryCometScale = 0.72;

  static const _circularRingPath = [
    1, 2, 3,
    9, 14, 19,
    23, 22, 21,
    15, 10, 5,
  ];

  static const int _loopLen = 12;

  @override
  Widget build(BuildContext context) {
    return DotMatrixBase(
      size: size,
      dotSize: dotSize,
      color: color,
      speed: speed,
      semanticsLabel: semanticsLabel,
      pattern: MatrixPattern.full,
      animated: animated,
      hoverAnimated: hoverAnimated,
      opacityBase: opacityBase,
      opacityMid: opacityMid,
      opacityPeak: opacityPeak,
      cellPadding: cellPadding,
      boxSize: boxSize,
      minSize: minSize,
      animationResolver: (ctx) {
        if (!isWithinCircularMask(ctx.row, ctx.col)) return null;

        final pathOrder = _circularRingPath.indexOf(ctx.index);
        final isCore = ctx.row == 2 && ctx.col == 2;
        if (pathOrder == -1) {
          return DotAnimationState(
              opacity: isCore ? _coreOpacity : _baseOpacity);
        }

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return DotAnimationState(
              opacity: _ringBaseOpacity +
                  (pathOrder / (_loopLen - 1)) * 0.56);
        }

        final headStep =
            (ctx.cyclePhase * _stepCount).floor() % _stepCount;
        final leadA =
            ((headStep / _stepCount) * _loopLen).floor() % _loopLen;
        final leadB = (leadA + _loopLen ~/ 2) % _loopLen;

        var opacity = _baseOpacity;
        for (var i = 0; i < _cometTail.length; i++) {
          final weight = _cometTail[i];
          final tailA = (leadA - i + _loopLen) % _loopLen;
          final tailB = (leadB - i + _loopLen) % _loopLen;
          if (pathOrder == tailA && weight > opacity) {
            opacity = weight;
          }
          if (pathOrder == tailB &&
              weight * _secondaryCometScale > opacity) {
            opacity = weight * _secondaryCometScale;
          }
        }

        return DotAnimationState(opacity: opacity < 1 ? opacity : 1.0);
      },
    );
  }
}
