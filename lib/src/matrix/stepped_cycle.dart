import 'package:flutter/widgets.dart';

/// Provides a discrete step index that cycles through [0, steps) at a
/// configurable rate. Equivalent to the React `useSteppedCycle` hook.
///
/// The step index is obtained from [value].
class SteppedCycleController {
  late final AnimationController controller;
  final TickerProvider _vsync;
  final int steps;

  bool _active = false;

  SteppedCycleController(
    this._vsync, {
    required this.steps,
    Duration cycleDuration = const Duration(milliseconds: 1500),
    bool initiallyActive = false,
  }) {
    assert(steps > 0, 'steps must be >= 1');
    controller = AnimationController(vsync: _vsync, duration: cycleDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && _active) {
          controller.repeat();
        }
      });
    if (initiallyActive) {
      controller.repeat();
    }
  }

  /// Current discrete step in [0, steps).
  int get value {
    final raw = (controller.value * steps).floor();
    return raw >= steps ? steps - 1 : raw;
  }

  /// Whether the cycle is currently running.
  bool get isActive => controller.isAnimating;

  /// Start the stepped cycle. Optionally pass a new [duration] to update the
  /// cycle speed.
  void start({Duration? duration}) {
    if (duration != null) controller.duration = duration;
    _active = true;
    if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  /// Stop the cycle and reset to step 0.
  void reset({int idleStep = 0}) {
    _active = false;
    controller.stop();
    controller.value = idleStep / steps;
  }

  void dispose() {
    _active = false;
    controller.dispose();
  }
}
