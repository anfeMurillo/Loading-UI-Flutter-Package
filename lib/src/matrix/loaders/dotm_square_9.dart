import 'package:flutter/material.dart';

import '../matrix_base.dart';

class GlyphPulseLoader extends StatelessWidget {
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

  const GlyphPulseLoader({
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

  static const double _baseOpacity = 0.08;
  static const double _midOpacity = 0.26;
  static const double _gapOpacity = 0.12;

  static const int _stepCount = 52;
  static const int _cellRowStart = 1;
  static const int _leftCol = 0;
  static const int _rightCellCol = 3;

  // Unicode/ISO braille dot bits
  static const int _d1 = 0x01;
  static const int _d2 = 0x02;
  static const int _d3 = 0x04;
  static const int _d4 = 0x08;
  static const int _d5 = 0x10;
  static const int _d6 = 0x20;

  static const int _checkA = _d1 | _d3 | _d5;

  // Peak step ranges [start, end) for each braille bit
  static const _peakRanges = <int, List<List<int>>>{
    _d1: [
      [2, 16],
      [24, 26],
      [28, 30],
      [34, 37],
      [42, 44],
      [46, 48],
    ],
    _d2: [
      [3, 13],
      [16, 19],
      [26, 28],
      [30, 32],
      [34, 40],
      [42, 44],
      [46, 48],
    ],
    _d3: [
      [4, 13],
      [19, 22],
      [24, 26],
      [28, 30],
      [37, 40],
      [42, 44],
      [46, 48],
    ],
    _d4: [
      [7, 16],
      [26, 28],
      [30, 32],
      [34, 37],
      [44, 46],
      [48, 50],
    ],
    _d5: [
      [8, 13],
      [16, 19],
      [24, 26],
      [28, 30],
      [34, 40],
      [44, 46],
      [48, 50],
    ],
    _d6: [
      [9, 13],
      [19, 22],
      [26, 28],
      [30, 32],
      [37, 40],
      [44, 46],
      [48, 50],
    ],
  };

  static bool _isBitPeak(int bit, int step) {
    final ranges = _peakRanges[bit];
    if (ranges == null) return false;
    for (final r in ranges) {
      if (step >= r[0] && step < r[1]) return true;
    }
    return false;
  }

  static int? _brailleBitForCell(int row, int col, int cellColStart) {
    if (row < _cellRowStart || row > _cellRowStart + 2) return null;
    final dr = row - _cellRowStart;
    if (col == cellColStart) return _d1 << dr;
    if (col == cellColStart + 1) return _d4 << dr;
    return null;
  }

  static ({int bit})? _resolveBraille(int row, int col) {
    final left = _brailleBitForCell(row, col, _leftCol);
    if (left != null) return (bit: left);
    final right = _brailleBitForCell(row, col, _rightCellCol);
    if (right != null) return (bit: right);
    return null;
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

        final braille = _resolveBraille(ctx.row, ctx.col);

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          if (braille != null) {
            final on = (_checkA & braille.bit) != 0;
            return DotAnimationState(
                opacity: on ? _midOpacity : _baseOpacity);
          }
          if (ctx.row >= _cellRowStart &&
              ctx.row <= _cellRowStart + 2 &&
              ctx.col == 2) {
            return const DotAnimationState(opacity: _gapOpacity);
          }
          return const DotAnimationState(opacity: _baseOpacity);
        }

        if (ctx.row >= _cellRowStart &&
            ctx.row <= _cellRowStart + 2 &&
            ctx.col == 2) {
          return const DotAnimationState(opacity: _gapOpacity);
        }

        if (braille == null) {
          return const DotAnimationState(opacity: _baseOpacity);
        }

        final step =
            (ctx.cyclePhase * _stepCount).floor() % _stepCount;
        final isOn = _isBitPeak(braille.bit, step);
        return DotAnimationState(
            opacity: isOn ? 1.0 : _baseOpacity);
      },
    );
  }
}
