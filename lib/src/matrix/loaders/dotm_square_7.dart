import 'package:flutter/material.dart';

import '../matrix_base.dart';

class BlockDropLoader extends StatelessWidget {
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

  const BlockDropLoader({
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
  static const double _settledOpacity = 0.42;
  static const double _activeOpacity = 1.0;
  static const double _clearOpacity = 0.88;

  static const List<String> _frameMasks = [
    '.....OOOOO....',
    '.....O....OOOO',
    '...OOO....OOOO',
    '..OOO......OOO',
    'OOOO.........O',
    'CCCC..........',
    '......CCCC....',
    'OOO...........',
    '..CCCC........',
    '..............',
  ];

  static const List<int> _frameSequence = [0, 1, 2, 3, 4, 4, 5, 6, 7, 8, 9];

  static String _cellAt(int frame, int row, int col) {
    final mask = _frameMasks[frame];
    final idx = row * 5 + col;
    if (idx >= mask.length) return '.';
    return mask[idx];
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

        final seqLen = _frameSequence.length;
        final step = (ctx.cyclePhase * seqLen).floor() % seqLen;
        final frame = _frameSequence[step];
        final cell = _cellAt(frame, ctx.row, ctx.col);

        return DotAnimationState(opacity: switch (cell) {
          'C' => _clearOpacity,
          'O' => _settledOpacity,
          'o' => _activeOpacity,
          _ => _baseOpacity,
        });
      },
    );
  }
}
