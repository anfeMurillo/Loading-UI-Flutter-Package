import 'package:flutter/material.dart';

import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import 'math_utils.dart';
import 'matrix_layout.dart';
import 'matrix_phases.dart';
import 'opacity_triplet.dart';
import 'path_wave_factory.dart';
import 'patterns.dart';

export 'matrix_phases.dart' show DotMatrixPhase;
export 'patterns.dart' show MatrixPattern;

class DotAnimationContext {
  final int index;
  final int row;
  final int col;
  final double distanceFromCenter;
  final double angleFromCenter;
  final double radiusNormalized;
  final double manhattanDistance;
  final DotMatrixPhase phase;
  final bool isActive;
  final bool reducedMotion;
  final double cyclePhase;

  const DotAnimationContext({
    required this.index,
    required this.row,
    required this.col,
    required this.distanceFromCenter,
    required this.angleFromCenter,
    required this.radiusNormalized,
    required this.manhattanDistance,
    required this.phase,
    required this.isActive,
    required this.reducedMotion,
    required this.cyclePhase,
  });
}

class DotAnimationState {
  final double? opacity;

  const DotAnimationState({this.opacity});

  const DotAnimationState.opacity(double value) : opacity = value;
}

typedef DotAnimationResolver = DotAnimationState? Function(
  DotAnimationContext ctx,
);

class DotMatrixBase extends StatefulWidget {
  final double? size;
  final double? dotSize;
  final Color? color;
  final double speed;
  final String? semanticsLabel;
  final MatrixPattern pattern;
  final bool muted;
  final bool animated;
  final bool hoverAnimated;
  final double? opacityBase;
  final double? opacityMid;
  final double? opacityPeak;
  final double? cellPadding;
  final double? boxSize;
  final double? minSize;
  final DotAnimationResolver? animationResolver;

  const DotMatrixBase({
    super.key,
    this.size,
    this.dotSize,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel,
    this.pattern = MatrixPattern.diamond,
    this.muted = false,
    this.animated = true,
    this.hoverAnimated = false,
    this.opacityBase,
    this.opacityMid,
    this.opacityPeak,
    this.cellPadding,
    this.boxSize,
    this.minSize,
    this.animationResolver,
  });

  @override
  State<DotMatrixBase> createState() => _DotMatrixBaseState();
}

class _DotMatrixBaseState extends State<DotMatrixBase>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  final DotMatrixPhases _phases = DotMatrixPhases();

  static const double defaultOpacityBase = 0.16;
  static const double defaultOpacityMid = 0.32;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _cycleDuration);
    _phases.addListener(_onPhaseChange);
  }

  Duration get _cycleDuration {
    final safeSpeed = widget.speed > 0 ? widget.speed : 1.0;
    final ms = (1500.0 / safeSpeed).round().clamp(1, 999999);
    return Duration(milliseconds: ms);
  }

  double get _defaultOpacity =>
      0.5 *
      ((widget.opacityBase ?? defaultOpacityBase) +
          (widget.opacityMid ?? defaultOpacityMid));

  double get _mutedOpacity =>
      0.44 * (widget.opacityMid ?? defaultOpacityMid);

  void _onPhaseChange() {
    _syncController();
    setState(() {});
  }

  void _syncParams() {
    final reducedMotion = reducedMotionOf(context);
    _phases.update(
      animated: widget.animated,
      hoverAnimated: widget.hoverAnimated,
      speed: widget.speed,
      reducedMotion: reducedMotion,
    );
    _syncController();
  }

  void _syncController() {
    final phase = _phases.phase;
    final reducedMotion = reducedMotionOf(context);
    final autoRun = widget.animated && !widget.hoverAnimated && !reducedMotion;

    if (autoRun || phase == DotMatrixPhase.hoverRipple) {
      _ctrl.duration = _cycleDuration;
      if (!_ctrl.isAnimating) {
        _ctrl.repeat();
      }
    } else if (phase == DotMatrixPhase.collapse) {
      _ctrl.stop();
      _ctrl.value = 0.0;
      final collapseMs =
          (300.0 / (widget.speed > 0 ? widget.speed : 1.0))
              .round()
              .clamp(1, 999999);
      _ctrl.duration = Duration(milliseconds: collapseMs);
      _ctrl.forward();
    } else {
      _ctrl.stop();
      _ctrl.value = 0.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncParams();
  }

  @override
  void didUpdateWidget(covariant DotMatrixBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    final paramsChanged = oldWidget.speed != widget.speed ||
        oldWidget.animated != widget.animated ||
        oldWidget.hoverAnimated != widget.hoverAnimated;
    if (paramsChanged) {
      _ctrl.duration = _cycleDuration;
      _syncParams();
    }
  }

  @override
  void dispose() {
    _phases.removeListener(_onPhaseChange);
    _phases.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  double _opacityForDot({
    required int index,
    required int row,
    required int col,
    required double distance,
    required double angle,
    required double radiusNorm,
    required double manhattan,
    required bool isActive,
    required double cyclePhase,
  }) {
    if (!isActive) return 0.0;

    final resolver = widget.animationResolver;
    if (resolver == null) {
      return widget.muted ? _mutedOpacity : _defaultOpacity;
    }

    final ctx = DotAnimationContext(
      index: index,
      row: row,
      col: col,
      distanceFromCenter: distance,
      angleFromCenter: angle,
      radiusNormalized: radiusNorm,
      manhattanDistance: manhattan,
      phase: _phases.phase,
      isActive: isActive,
      reducedMotion: reducedMotionOf(context),
      cyclePhase: cyclePhase,
    );

    final state = resolver(ctx);
    if (state == null) return widget.muted ? _mutedOpacity : _defaultOpacity;

    if (state.opacity != null) {
      return remapOpacityToTriplet(
        state.opacity!,
        widget.opacityBase,
        widget.opacityMid,
        widget.opacityPeak,
      );
    }

    return widget.muted ? _mutedOpacity : _defaultOpacity;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size ?? 24.0;
    final effectiveDotSize = widget.dotSize ?? (effectiveSize / 8);
    final color = resolveColor(context, widget.color);

    final layout = getMatrix5Layout(
      effectiveSize,
      effectiveDotSize,
      widget.cellPadding,
    );
    final matrixSpan = widget.cellPadding != null
        ? layout.matrixSpan
        : effectiveSize;

    final wrapperResult = resolveDmxBoxOuterDim(
      boxSize: widget.boxSize,
      minSize: widget.minSize,
    );

    final activeMask =
        List<bool>.generate(matrixSize * matrixSize, (i) => false);
    for (final idx in getPatternIndexes(widget.pattern)) {
      activeMask[idx] = true;
    }

    final dotMetas = <({int index, int row, int col, double distance,
            double angle, double radiusNorm, double manhattan})>[
      for (var i = 0; i < matrixSize * matrixSize; i++)
        (
          index: i,
          row: i ~/ matrixSize,
          col: i % matrixSize,
          distance: distanceFromCenter(i),
          angle: polarAngle(i),
          radiusNorm: normalizedRadius(i),
          manhattan: manhattanDistance(i).toDouble(),
        ),
    ];

    Widget buildGrid(double t) {
      return SizedBox(
        width: matrixSpan,
        height: matrixSpan,
        child: Wrap(
          spacing: layout.gap,
          runSpacing: layout.gap,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: List<Widget>.generate(matrixSize * matrixSize, (i) {
            final meta = dotMetas[i];
            final isActive = activeMask[meta.index];
            final opacity = _opacityForDot(
              index: meta.index,
              row: meta.row,
              col: meta.col,
              distance: meta.distance,
              angle: meta.angle,
              radiusNorm: meta.radiusNorm,
              manhattan: meta.manhattan,
              isActive: isActive,
              cyclePhase: t,
            );

            return Opacity(
              opacity: opacity,
              child: Container(
                width: effectiveDotSize,
                height: effectiveDotSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      );
    }

    Widget content = AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => buildGrid(_ctrl.value),
    );

    if (widget.hoverAnimated && widget.boxSize == null) {
      content = MouseRegion(
        onEnter: (_) => _phases.onEnter(),
        onExit: (_) => _phases.onExit(),
        child: content,
      );
    }

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: wrapperResult.useWrapper ? wrapperResult.outerDim : null,
      child: content,
    );
  }
}

class PathWaveMatrix extends StatelessWidget {
  final PathNormFn pathNorm;
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

  const PathWaveMatrix({
    super.key,
    required this.pathNorm,
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
      animationResolver: createPathWaveResolver(pathNorm),
    );
  }
}
