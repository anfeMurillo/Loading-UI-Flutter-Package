import 'package:flutter/widgets.dart';

/// Wraps an [AnimationController] to provide a continuous normalised cycle
/// phase in [0, 1), equivalent to the React `useCyclePhase` hook.
///
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with SingleTickerProviderStateMixin {
///   late final CyclePhaseController _cycle = CyclePhaseController(this);
///
///   void _updateAnimation(bool active) {
///     if (active) {
///       _cycle.start();
///     } else {
///       _cycle.reset();
///     }
///   }
///
///   @override
///   void dispose() {
///     _cycle.dispose();
///     super.dispose();
///   }
/// }
/// ```
class CyclePhaseController {
  late final AnimationController controller;
  final TickerProvider _vsync;

  CyclePhaseController(
    this._vsync, {
    Duration duration = const Duration(milliseconds: 1500),
    bool initiallyActive = false,
  }) {
    controller = AnimationController(vsync: _vsync, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && _active) {
          controller.repeat();
        }
      });
    if (initiallyActive) {
      controller.repeat();
    }
  }

  double get value => controller.value;

  bool _active = false;

  bool get isActive => controller.isAnimating;

  void start({Duration? duration}) {
    if (duration != null) controller.duration = duration;
    _active = true;
    if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  void reset() {
    _active = false;
    controller.stop();
    controller.value = 0.0;
  }

  void dispose() {
    _active = false;
    controller.dispose();
  }
}
