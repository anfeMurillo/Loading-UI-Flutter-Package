import 'package:flutter/material.dart';

import '../grid_paths.dart';
import '../matrix_base.dart';

class ConcentricRingMatrixLoader extends StatelessWidget {
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

  const ConcentricRingMatrixLoader({
    super.key,
    this.size,
    this.dotSize,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel,
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
  Widget build(BuildContext context) {
    return PathWaveMatrix(
      pathNorm: ({required row, required col, required index}) =>
          concentricRingNormFromIndex(index),
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
    );
  }
}
