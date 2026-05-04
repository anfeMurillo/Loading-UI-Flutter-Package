import 'dart:math' as math;

enum MatrixPattern { diamond, full, outline, rose, cross, rings }

const int matrixSize = 5;

final int _center = matrixSize ~/ 2;

int rowMajorIndex(int row, int col) => row * matrixSize + col;

({int row, int col}) indexToCoord(int index) => (
      row: index ~/ matrixSize,
      col: index % matrixSize,
    );

double distanceFromCenter(int index) {
  final coord = indexToCoord(index);
  return math.sqrt(
    (coord.row - _center) * (coord.row - _center) +
        (coord.col - _center) * (coord.col - _center),
  );
}

double rowDistance(int index) {
  final row = index ~/ matrixSize;
  return (row - _center).abs().toDouble();
}

final List<int> fullIndexes =
    List<int>.generate(matrixSize * matrixSize, (i) => i);

final List<int> diamondIndexes = fullIndexes.where((index) {
  final coord = indexToCoord(index);
  return (coord.row - _center).abs() + (coord.col - _center).abs() <= 2;
}).toList();

final List<int> outlineIndexes = fullIndexes.where((index) {
  final coord = indexToCoord(index);
  return coord.row == 0 ||
      coord.row == matrixSize - 1 ||
      coord.col == 0 ||
      coord.col == matrixSize - 1;
}).toList();

final List<int> crossIndexes = fullIndexes.where((index) {
  final coord = indexToCoord(index);
  return coord.row == _center || coord.col == _center;
}).toList();

final List<int> ringsIndexes = fullIndexes.where((index) {
  final radius = distanceFromCenter(index);
  return radius.round() == 1 || radius.round() == 2;
}).toList();

final List<int> roseIndexes = fullIndexes.where((index) {
  final coord = indexToCoord(index);
  final dx = coord.col - _center;
  final dy = coord.row - _center;
  final angle = math.atan2(dy.toDouble(), dx.toDouble());
  final radius = math.sqrt(dx * dx + dy * dy);
  final rose = math.sin(3 * angle).abs();
  return rose > 0.6 && radius >= 1;
}).toList();

final Map<MatrixPattern, List<int>> _patternIndexes = {
  MatrixPattern.diamond: diamondIndexes,
  MatrixPattern.full: fullIndexes,
  MatrixPattern.outline: outlineIndexes,
  MatrixPattern.rose: roseIndexes,
  MatrixPattern.cross: crossIndexes,
  MatrixPattern.rings: ringsIndexes,
};

List<int> getPatternIndexes([MatrixPattern pattern = MatrixPattern.diamond]) =>
    _patternIndexes[pattern]!;
