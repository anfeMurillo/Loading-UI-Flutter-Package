import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../circle_mask.dart';
import '../matrix_base.dart';

class StarCompassLoader extends StatelessWidget {
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

  const StarCompassLoader({
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

  static const int _stepCount = 36;
  static const double _baseOpacity = 0.07;
  static const double _midOpacity = 0.28;
  static const double _starOpacity = 0.96;

  static const _cardinalCenters = [0.0, math.pi / 2, math.pi, -math.pi / 2];

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

        final x = (ctx.col - 2).toDouble();
        final y = (ctx.row - 2).toDouble();
        final ring =
            math.sqrt(x * x + y * y);
        final angle = math.atan2(y, x);
        final beaconIndex = (ctx.reducedMotion ||
                ctx.phase == DotMatrixPhase.idle
            ? 0
            : ((ctx.cyclePhase * _stepCount).floor() /
                    _stepCount *
                    _cardinalCenters.length)
                .floor() %
                _cardinalCenters.length);
        final activeCenter = _cardinalCenters[beaconIndex];
        final oppositeCenter =
            _cardinalCenters[(beaconIndex + 2) % _cardinalCenters.length];

        final distanceToActive =
            math.acos(math.cos(angle - activeCenter));
        final distanceToOpposite =
            math.acos(math.cos(angle - oppositeCenter));
        final activeBeam =
            (1 - distanceToActive / 0.5).clamp(0.0, 1.0);
        final oppositeBeam =
            (1 - distanceToOpposite / 0.65).clamp(0.0, 1.0);
        final ringTier = ring.round();

        var opacity = _baseOpacity;
        if (activeBeam > 0.8 && ringTier >= 2) {
          opacity = _starOpacity;
        } else if (activeBeam > 0.45 && ringTier >= 1) {
          opacity = 0.62;
        } else if (oppositeBeam > 0.5 && ringTier >= 1) {
          opacity = _midOpacity;
        }

        if (x == 0 && y == 0) {
          opacity = opacity > 0.24 ? opacity : 0.24;
        }

        return DotAnimationState(opacity: opacity);
      },
    );
  }
}
