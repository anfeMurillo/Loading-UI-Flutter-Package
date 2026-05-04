double _keyframe(double t, List<double> stops, List<double> values) {
  for (var i = 0; i < stops.length - 1; i++) {
    if (t <= stops[i + 1]) {
      final span = stops[i + 1] - stops[i];
      final segT = span == 0 ? 0.0 : ((t - stops[i]) / span).clamp(0.0, 1.0);
      return values[i] + (values[i + 1] - values[i]) * segT;
    }
  }
  return values.last;
}

double rippleOpacity(double t, double base, double peak) =>
    _keyframe(t, const [0, 0.5, 1.0], [base, peak, base]);

double rippleEchoOpacity(double t, double base, double mid, double peak) =>
    _keyframe(t, const [0, 0.28, 0.56, 0.78, 1.0], [
      0.625 * base,
      0.98 * peak,
      mid,
      0.68 * peak + 0.32 * mid,
      0.625 * base,
    ]);

double centerOriginRippleOpacity(
  double t,
  double base,
  double mid,
  double peak,
) =>
    _keyframe(t, const [0, 0.34, 0.60, 1.0], [
      0.625 * base,
      peak,
      0.5 * (base + mid),
      0.625 * base,
    ]);

double hoverRippleOpacity(double t, double base, double peak) =>
    _keyframe(t, const [0, 0.45, 1.0], [0.5 * base, peak, base]);

double diagonalAltSweepOpacity(double t, double base, double peak) =>
    _keyframe(t, const [0, 0.14, 0.30, 1.0], [
      0.5 * base,
      peak,
      0.75 * base,
      0.5 * base,
    ]);

double spiralSnakeOpacity(double t, double base, double mid, double peak) =>
    _keyframe(t, const [0, 0.08, 0.16, 0.24, 0.32, 0.40, 1.0], [
      0.5 * base,
      peak,
      0.5 * peak + 0.4 * mid + 0.1 * base,
      0.25 * peak + 0.45 * mid + 0.3 * base,
      0.5 * mid + 0.5 * base,
      0.75 * base,
      0.5 * base,
    ]);

double ringSnakeOpacity(double t, double base, double mid, double peak) =>
    _keyframe(t, const [0, 0.10, 0.20, 0.30, 0.40, 1.0], [
      0.5 * base,
      peak,
      0.45 * peak + 0.45 * mid + 0.1 * base,
      0.2 * peak + 0.4 * mid + 0.4 * base,
      0.875 * base,
      0.5 * base,
    ]);

double collapseOpacity(double t, double base, double mid, double peak) {
  final start = 0.95 * peak + 0.05 * mid;
  final end = 0.375 * base;
  return start + (end - start) * t;
}

double colSnakeOpacity(double t, double base, double mid, double peak) =>
    _keyframe(t, const [0, 0.20, 0.40, 0.60, 0.80, 1.0], [
      0.6 * peak + 0.25 * mid + 0.15 * base,
      0.3 * peak + 0.5 * mid + 0.2 * base,
      0.6 * mid + 0.4 * base,
      0.2 * mid + 0.8 * base,
      0.625 * base,
      0.625 * base,
    ]);

double _calcCircularRingValue(int segment, double base, double mid, double peak) {
  return switch (segment) {
    0 => peak,
    1 => 0.6 * peak + 0.4 * mid,
    2 => 0.5 * mid + 0.5 * base,
    3 => 0.3 * mid + 0.7 * base,
    _ => 0.3 * mid + 0.7 * base,
  };
}

double circularRingOpacity(double t, double base, double mid, double peak) {
  const stepCount = 12;
  final rawStep = (t * stepCount).floor();
  final step = rawStep >= stepCount ? stepCount - 1 : rawStep;
  return _calcCircularRingValue(step % 4, base, mid, peak);
}

/// Default idle opacity gradient from path norm [0..1].
double idlePathOpacity(double pathNorm) => 0.12 + pathNorm * 0.72;
