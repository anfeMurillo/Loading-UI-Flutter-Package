import 'package:flutter/material.dart';

import '../matrix_base.dart';
import '../patterns.dart';

class PrismBloomLoader extends StatelessWidget {
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

  const PrismBloomLoader({
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
  static const double _midOpacity = 0.52;
  static const double _peakOpacity = 1.0;

  static const _frameMasks = [
    'x...x' '.x.x.' '..o..' '.x.x.' 'x...x',
    '..x..' '.oxo.' 'xooox' '.oxo.' '..x..',
    '.x.x.' 'x.o.x' '..o..' 'x.o.x' '.x.x.',
    'x.x.x' '.o.o.' 'x.o.x' '.o.o.' 'x.x.x',
  ];

  static const _frameSequence = [0, 1, 2, 3, 2, 1];

  static String _cellFromMask(String mask, int row, int col) {
    final idx = rowMajorIndex(row, col);
    return idx < mask.length ? mask[idx] : '.';
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

        final sequenceLen = _frameSequence.length;
        final step = (ctx.cyclePhase * sequenceLen).floor() % sequenceLen;
        final frameIndex = _frameSequence[step];
        final mask = _frameMasks[frameIndex];

        final cell = _cellFromMask(mask, ctx.row, ctx.col);
        if (cell == 'x') {
          return const DotAnimationState(opacity: _peakOpacity);
        }
        if (cell == 'o') {
          return const DotAnimationState(opacity: _midOpacity);
        }
        return const DotAnimationState(opacity: _baseOpacity);
      },
    );
  }
}
