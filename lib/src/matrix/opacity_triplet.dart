const double sourceBaseOpacity = 0.08;
const double sourceMidOpacity = 0.34;
const double sourcePeakOpacity = 0.94;

double _clamp01(double value) {
  if (!value.isFinite) return 0;
  return value.clamp(0.0, 1.0);
}

double _lerp(double start, double end, double progress) =>
    start + (end - start) * progress;

double _normalizeProgress(double value, double start, double end) {
  final span = end - start;
  if (span.abs() < 1e-10) return 0;
  return _clamp01((value - start) / span);
}

double? _coerceOpacity(double? value) {
  if (value == null || !value.isFinite) return null;
  return _clamp01(value);
}

double remapOpacityToTriplet(
  double opacity, [
  double? opacityBase,
  double? opacityMid,
  double? opacityPeak,
]) {
  if (!opacity.isFinite) return opacity;

  final hasOverrides =
      opacityBase != null || opacityMid != null || opacityPeak != null;
  if (!hasOverrides) return _clamp01(opacity);

  final targetBase = _coerceOpacity(opacityBase) ?? sourceBaseOpacity;
  final targetMid = _coerceOpacity(opacityMid) ?? sourceMidOpacity;
  final targetPeak = _coerceOpacity(opacityPeak) ?? sourcePeakOpacity;

  final safeOpacity = _clamp01(opacity);

  if (safeOpacity <= sourceBaseOpacity) {
    final progress = _normalizeProgress(safeOpacity, 0, sourceBaseOpacity);
    return _clamp01(_lerp(0, targetBase, progress));
  }

  if (safeOpacity <= sourceMidOpacity) {
    final progress =
        _normalizeProgress(safeOpacity, sourceBaseOpacity, sourceMidOpacity);
    return _clamp01(_lerp(targetBase, targetMid, progress));
  }

  if (safeOpacity <= sourcePeakOpacity) {
    final progress =
        _normalizeProgress(safeOpacity, sourceMidOpacity, sourcePeakOpacity);
    return _clamp01(_lerp(targetMid, targetPeak, progress));
  }

  final progress = _normalizeProgress(safeOpacity, sourcePeakOpacity, 1);
  return _clamp01(_lerp(targetPeak, 1, progress));
}
