import 'package:flutter/animation.dart';

double phaseOf(double v, double offset) {
  final t = (v - offset) % 1.0;
  return t < 0 ? t + 1.0 : t;
}

double lerpStops(
  double t,
  List<double> stops,
  List<double> values, {
  Curve curve = Curves.linear,
}) {
  assert(stops.length == values.length && stops.length >= 2);
  for (var i = 0; i < stops.length - 1; i++) {
    if (t <= stops[i + 1]) {
      final span = stops[i + 1] - stops[i];
      final segT = span == 0 ? 0.0 : ((t - stops[i]) / span).clamp(0.0, 1.0);
      final eased = curve.transform(segT);
      return values[i] + (values[i + 1] - values[i]) * eased;
    }
  }
  return values.last;
}
