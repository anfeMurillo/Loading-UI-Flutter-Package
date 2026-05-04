import 'package:flutter/material.dart';

import '../matrix_base.dart';

class StrobeStackLoader extends StatelessWidget {
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

  const StrobeStackLoader({
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

  static const int _rows = 5;
  static const int _cols = 5;

  static const int _fillLast = _rows + _cols - 1;
  static const int _blinkSteps = 4;
  static const List<double> _blinkOpacities = [0.38, 1.0, 0.38, 1.0];
  static const int _drainLast = _fillLast;

  static const int _sequenceLen =
      _fillLast + 1 + _blinkSteps + _drainLast + 1;

  static const double _baseOpacity = 0.08;
  static const double _settledOpacity = 0.52;
  static const double _capOpacity = 1.0;

  static int _fillHeight(int col, int fillTick) {
    return (fillTick - col).clamp(0, _rows);
  }

  static int _drainHeight(int col, int drainTick) {
    final remaining = _rows - (drainTick - col).clamp(0, _rows);
    return remaining.clamp(0, _rows);
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

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          return const DotAnimationState(opacity: _baseOpacity);
        }

        final step =
            (ctx.cyclePhase * _sequenceLen).floor() % _sequenceLen;

        var height = 0;
        double? blinkOpacity;

        if (step <= _fillLast) {
          height = _fillHeight(ctx.col, step);
        } else if (step < _fillLast + 1 + _blinkSteps) {
          height = _rows;
          blinkOpacity =
              _blinkOpacities[step - (_fillLast + 1)];
        } else {
          final drainTick = step - (_fillLast + 1 + _blinkSteps);
          height = _drainHeight(ctx.col, drainTick);
        }

        final topLitRow = _rows - height;
        final isLit =
            height > 0 && ctx.row >= topLitRow && ctx.row <= _rows - 1;
        if (!isLit) {
          return const DotAnimationState(opacity: _baseOpacity);
        }

        if (blinkOpacity != null) {
          return DotAnimationState(opacity: blinkOpacity);
        }

        final isCap =
            ctx.row == topLitRow && height > 0 && height < _rows;
        return DotAnimationState(
            opacity: isCap ? _capOpacity : _settledOpacity);
      },
    );
  }
}
