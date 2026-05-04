import 'patterns.dart';

({double gap, double matrixSpan}) getMatrix5Layout(
  double size,
  double dotSize, [
  double? cellPadding,
]) {
  const n = matrixSize;
  if (cellPadding != null) {
    final gap = cellPadding < 0 ? 0.0 : cellPadding;
    final matrixSpan = dotSize * n + gap * (n - 1);
    return (gap: gap, matrixSpan: matrixSpan);
  }
  final gap =
      ((size - dotSize * n) / (n - 1)).floorToDouble().clamp(1.0, double.infinity);
  return (gap: gap, matrixSpan: size);
}

({double outerDim, bool useWrapper}) resolveDmxBoxOuterDim({
  double? boxSize,
  double? minSize,
}) {
  final b = boxSize;
  final hasBox = b != null && b > 0 && b.isFinite;
  if (!hasBox) {
    return (outerDim: 0.0, useWrapper: false);
  }
  final m = minSize;
  if (m != null && m > 0 && m.isFinite) {
    return (outerDim: b > m ? b : m, useWrapper: true);
  }
  return (outerDim: b, useWrapper: true);
}
