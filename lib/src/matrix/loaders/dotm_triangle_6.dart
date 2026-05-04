import 'package:flutter/material.dart';

import '../triangle_base.dart';

class BrailleBeatLoader extends StatelessWidget {
  final double size;
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

  const BrailleBeatLoader({
    super.key,
    this.size = 30.0,
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
  });

  static const double _lowOpacity = 0.07;
  static const double _midOpacity = 0.36;
  static const double _highOpacity = 0.96;

  static const double _waveHalf = 0.82;
  static const double _introPhase = 0.52;
  static const double _blinkPhase = 0.36;
  static const double _resetPhase = 0.12;

  static const int _d1 = 0x01;
  static const int _d2 = 0x02;
  static const int _d3 = 0x04;
  static const int _d4 = 0x08;
  static const int _d5 = 0x10;
  static const int _d6 = 0x20;

  static const _bitToFillIndex = {
    _d1: 0,
    _d2: 1,
    _d3: 2,
    _d4: 3,
    _d5: 4,
    _d6: 5,
  };

  static double _smoothstep01(double edge0, double edge1, double x) {
    if (edge1 <= edge0) return x >= edge1 ? 1.0 : 0.0;
    final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static List<double> _waveFills(double introT) {
    final waveCenter = -_waveHalf + introT * (5 + 2 * _waveHalf);
    return [0, 1, 2, 3, 4, 5].map((i) =>
        _smoothstep01(i - _waveHalf, i + _waveHalf, waveCenter)).toList();
  }

  static int? _brailleBitForTriangle(int row, int col) {
    if (row == 2 && col == 2) return _d1;
    if (row == 3 && col == 1) return _d2;
    if (row == 4 && col == 0) return _d3;
    if (row == 2 && col == 4) return _d4;
    if (row == 3 && col == 5) return _d5;
    if (row == 4 && col == 6) return _d6;
    return null;
  }

  static double _meanFills(List<int> indices, List<double> fills) {
    var s = 0.0;
    for (final i in indices) {
      s += fills[i];
    }
    return s / indices.length;
  }

  static ({List<double> fills, double blinkMul, double resetMul}) _cycleParams(
      double phase) {
    if (phase < _introPhase) {
      final introT = phase / _introPhase;
      return (fills: _waveFills(introT), blinkMul: 1.0, resetMul: 1.0);
    }
    if (phase < _introPhase + _blinkPhase) {
      final bt = (phase - _introPhase) / _blinkPhase;
      final on = (bt * 4).floor() % 2 == 0;
      return (
        fills: List.filled(6, 1.0),
        blinkMul: on ? 1.0 : 0.08,
        resetMul: 1.0
      );
    }
    final rt =
        (phase - _introPhase - _blinkPhase) / _resetPhase;
    final resetMul = 1 - _smoothstep01(0, 1, rt);
    return (fills: List.filled(6, 1.0), blinkMul: 1.0, resetMul: resetMul);
  }

  static double _opacityForCell(
    int row,
    int col,
    List<double> fills,
    double blinkMul,
    double resetMul,
  ) {
    double lift(double base) =>
        _lowOpacity + (base - _lowOpacity) * blinkMul * resetMul;

    final bit = _brailleBitForTriangle(row, col);
    if (bit != null) {
      final idx = _bitToFillIndex[bit] ?? 0;
      final raw = _lowOpacity +
          (_highOpacity - _lowOpacity) * fills[idx];
      return lift(raw);
    }

    if (row == 1 && col == 3) {
      final m = _meanFills([0, 3], fills);
      final raw = _lowOpacity +
          (_highOpacity - _lowOpacity) * m * 0.92 +
          (_midOpacity - _lowOpacity) * (1 - m) * 0.35;
      return lift(raw < _highOpacity ? raw : _highOpacity);
    }
    if (row == 3 && col == 3) {
      final m = _meanFills([0, 1, 2, 3, 4, 5], fills);
      final raw = _lowOpacity +
          (_highOpacity - _lowOpacity) * m * 0.88 +
          (_midOpacity - _lowOpacity) * (1 - m) * 0.4;
      return lift(raw < _highOpacity ? raw : _highOpacity);
    }
    if (row == 4 && col == 2) {
      final m = _meanFills([1, 2], fills);
      final raw = _lowOpacity + (_midOpacity + 0.28 - _lowOpacity) * m;
      return lift(raw);
    }
    if (row == 4 && col == 4) {
      final m = _meanFills([4, 5], fills);
      final raw = _lowOpacity + (_midOpacity + 0.28 - _lowOpacity) * m;
      return lift(raw);
    }

    return _lowOpacity;
  }

  @override
  Widget build(BuildContext context) {
    return TriangleMatrixBase(
      size: size,
      dotSize: dotSize,
      color: color,
      speed: speed,
      semanticsLabel: semanticsLabel,
      animated: animated,
      hoverAnimated: hoverAnimated,
      opacityBase: opacityBase,
      opacityMid: opacityMid,
      opacityPeak: opacityPeak,
      cellPadding: cellPadding,
      opacityResolver: (ctx) {
        if (!ctx.isActive) return 0.0;

        if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
          const fills = [0.55, 0.55, 0.55, 0.55, 0.55, 0.55];
          return _opacityForCell(
              ctx.row, ctx.col, fills, 1.0, 1.0);
        }

        final (:fills, :blinkMul, :resetMul) =
            _cycleParams(ctx.cyclePhase);
        return _opacityForCell(
            ctx.row, ctx.col, fills, blinkMul, resetMul);
      },
    );
  }
}
