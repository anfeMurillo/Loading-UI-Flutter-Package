import 'dart:async';

import 'package:flutter/widgets.dart';

/// The four canonical dot-matrix animation phases, mirroring the React
/// `DotMatrixPhase` type.
enum DotMatrixPhase {
  /// Default rest state — static opacity gradient.
  idle,

  /// Quick collapse animation on pointer enter (300 ms / speed).
  collapse,

  /// Continuous hover ripple after collapse completes.
  hoverRipple,

  /// Continuous loading ripple when [animated] is true.
  loadingRipple,
}

/// Manages the 4-state phase machine for a dot-matrix loader:
/// `idle` → `collapse` → `hoverRipple` → `idle`, or directly
/// `loadingRipple` when [animated] is true.
///
/// Usage:
/// ```dart
/// final phases = DotMatrixPhases();
/// // In build: wrap with MouseRegion(onEnter: phases.onEnter, onExit: phases.onExit)
/// // Read: phases.phase
/// // Update: phases.update(animated: true, hoverAnimated: false)
/// // Cleanup: phases.dispose()
/// ```
class DotMatrixPhases extends ChangeNotifier {
  DotMatrixPhase _phase = DotMatrixPhase.idle;
  int _hoverGen = 0;
  Timer? _collapseTimer;
  final List<Timer> _pendingTimers = [];

  DotMatrixPhase get phase => _phase;

  bool _animated = false;
  bool _hoverAnimated = false;
  double _speed = 1.0;
  bool _reducedMotion = false;

  void update({
    bool animated = false,
    bool hoverAnimated = false,
    double speed = 1.0,
    bool reducedMotion = false,
  }) {
    final autoRun = animated && !hoverAnimated && !reducedMotion;
    final safeSpeed = speed > 0 ? speed : 1.0;

    _animated = animated;
    _hoverAnimated = hoverAnimated;
    _speed = safeSpeed;
    _reducedMotion = reducedMotion;

    _clearTimers();

    if (autoRun) {
      _setPhase(DotMatrixPhase.loadingRipple);
    } else {
      _setPhase(DotMatrixPhase.idle);
    }
  }

  void onEnter() {
    if (!_hoverAnimated || (_animated && !_reducedMotion)) return;

    _clearTimers();
    _hoverGen += 1;
    final gen = _hoverGen;
    _setPhase(DotMatrixPhase.collapse);

    final collapseMs = (300 / _speed).round().clamp(1, 999999);
    _collapseTimer = Timer(Duration(milliseconds: collapseMs), () {
      if (_hoverGen != gen) return;
      _setPhase(DotMatrixPhase.hoverRipple);
    });
  }

  void onExit() {
    if (!_hoverAnimated) return;
    _hoverGen += 1;
    _clearTimers();
    _setPhase(DotMatrixPhase.idle);
  }

  void _setPhase(DotMatrixPhase newPhase) {
    if (_phase != newPhase) {
      _phase = newPhase;
      notifyListeners();
    }
  }

  void _clearTimers() {
    _collapseTimer?.cancel();
    _collapseTimer = null;
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
  }

  @override
  void dispose() {
    _clearTimers();
    super.dispose();
  }
}
