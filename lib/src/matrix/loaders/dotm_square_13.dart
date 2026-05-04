import 'package:flutter/material.dart';

import '../matrix_base.dart';
import '../patterns.dart';

class CoreRotorLoader extends StatelessWidget {
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

  const CoreRotorLoader({
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
  static const double _onOpacity = 0.56;
  static const double _peakOpacity = 1.0;

  static const List<String> _frameMasks = [
    '..x....x....o...................', // N
    '....x...x...o...................', // NE
    '...............oxx..............', // E
    '...............o....x....x......', // SE
    '...............o...x....x.......', // S
    '...............o..x....x........', // SW
    '...............xxo...............', // W
    'x.....x......o...................', // NW
  ];

  static const _frameSequence = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7];

  static String _maskCell(String mask, int row, int col) {
    final i = rowMajorIndex(row, col);
    return mask[i];
  }

  @override
  Widget build(BuildContext context) {
    const sequenceLen = 16;

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

        // Use stepped cycle: cycleMsBase=1550, steps=16
        final step = (ctx.cyclePhase * sequenceLen).floor() % sequenceLen;
        final frameIndex = _frameSequence[step];
        final mask = _frameMasks[frameIndex];
        final cell = _maskCell(mask, ctx.row, ctx.col);

        return DotAnimationState(
          opacity: switch (cell) {
            'x' => _peakOpacity,
            'o' => _onOpacity,
            _ => _baseOpacity,
          },
        );
      },
    );
  }
}
