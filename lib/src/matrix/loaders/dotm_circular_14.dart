import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class RungShiftLoader extends StatelessWidget {
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

  const RungShiftLoader({
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

  static const double _baseOpacity = 0.07;
  static const double _rungOpacity = 0.95;
  static const double _sideOpacity = 0.56;
  static const double _ghostOpacity = 0.28;

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

        final x = ctx.col.toDouble();
        final y = ctx.row.toDouble();
        final phaseStep = ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle
            ? 0
            : (ctx.cyclePhase * 10).floor();
        final activeRow = (phaseStep + 5) % 5;
        final rowDistance = (ctx.row - activeRow).abs();
        final swing = math.sin(
            (phaseStep / 10) * math.pi * 2 + ctx.row * 0.9);
        final leftAnchor = (1 + swing).round();
        final rightAnchor = 4 - leftAnchor;

        var opacity = _baseOpacity;
        if (ctx.row == activeRow &&
            ctx.col >= leftAnchor &&
            ctx.col <= rightAnchor) {
          opacity = _rungOpacity;
        } else if ((ctx.col == leftAnchor || ctx.col == rightAnchor) &&
            rowDistance <= 1) {
          opacity = _sideOpacity;
        } else if ((ctx.col == leftAnchor || ctx.col == rightAnchor) &&
            rowDistance == 2) {
          opacity = _ghostOpacity;
        }

        if (x == 2 && y == 2 && rowDistance <= 1) {
          opacity = math.max(opacity, _sideOpacity);
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
