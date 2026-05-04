import 'package:flutter/material.dart';

import '../core/color_resolver.dart';
import '../core/loader_base.dart';
import 'matrix_phases.dart';
import 'opacity_triplet.dart';

export 'matrix_phases.dart' show DotMatrixPhase;

class DotTriangleContext {
  final int index;
  final int row;
  final int col;
  final DotMatrixPhase phase;
  final bool isActive;
  final bool reducedMotion;
  final double cyclePhase;

  const DotTriangleContext({
    required this.index,
    required this.row,
    required this.col,
    required this.phase,
    required this.isActive,
    required this.reducedMotion,
    required this.cyclePhase,
  });
}

typedef DotTriangleResolver = double Function(DotTriangleContext ctx);

class TriangleMatrixBase extends StatefulWidget {
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
  final DotTriangleResolver opacityResolver;

  const TriangleMatrixBase({
    super.key,
    this.size = 30.0,
    this.dotSize,
    this.color,
    this.speed = 1.0,
    this.semanticsLabel,
    this.animated = true,
    this.hoverAnimated = false,
    this.opacityBase,
    this.opacityMid,
    this.opacityPeak,
    this.cellPadding,
    required this.opacityResolver,
  });

  @override
  State<TriangleMatrixBase> createState() => _TriangleMatrixBaseState();
}

class _TriangleMatrixBaseState extends State<TriangleMatrixBase>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final DotMatrixPhases _phases = DotMatrixPhases();

  static const int matrixSize = 7;

  static const triangleCells = {
    (1, 3),
    (2, 2),
    (2, 4),
    (3, 1),
    (3, 3),
    (3, 5),
    (4, 0),
    (4, 2),
    (4, 4),
    (4, 6),
  };

  bool _isActive(int row, int col) => triangleCells.contains((row, col));

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
    final autoRun =
        widget.animated && !widget.hoverAnimated && !reducedMotion;

    if (autoRun || phase == DotMatrixPhase.hoverRipple) {
      _ctrl.duration = _cycleDuration;
      if (!_ctrl.isAnimating) _ctrl.repeat();
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
  void didUpdateWidget(covariant TriangleMatrixBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed ||
        oldWidget.animated != widget.animated ||
        oldWidget.hoverAnimated != widget.hoverAnimated) {
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

  @override
  Widget build(BuildContext context) {
    final color = resolveColor(context, widget.color);
    final effectiveDotSize = widget.dotSize ?? (widget.size / 7.5);
    final gap = widget.cellPadding ??
        ((widget.size - effectiveDotSize * matrixSize) /
                (matrixSize - 1))
            .floorToDouble()
            .clamp(1.0, double.infinity);
    final gridSpan = widget.cellPadding != null
        ? effectiveDotSize * matrixSize + gap * (matrixSize - 1)
        : widget.size;

    Widget grid = AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => SizedBox(
        width: gridSpan,
        height: gridSpan,
        child: Wrap(
          spacing: gap,
          runSpacing: gap,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: List<Widget>.generate(
              matrixSize * matrixSize, (index) {
            final row = index ~/ matrixSize;
            final col = index % matrixSize;
            final isActive = _isActive(row, col);

            final opacity = isActive
                ? remapOpacityToTriplet(
                    widget.opacityResolver(DotTriangleContext(
                      index: index,
                      row: row,
                      col: col,
                      phase: _phases.phase,
                      isActive: true,
                      reducedMotion: reducedMotionOf(context),
                      cyclePhase: _ctrl.value,
                    )),
                    widget.opacityBase,
                    widget.opacityMid,
                    widget.opacityPeak,
                  )
                : 0.0;

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
      ),
    );

    if (widget.hoverAnimated) {
      grid = MouseRegion(
        onEnter: (_) => _phases.onEnter(),
        onExit: (_) => _phases.onExit(),
        child: grid,
      );
    }

    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: gridSpan,
      child: grid,
    );
  }
}
