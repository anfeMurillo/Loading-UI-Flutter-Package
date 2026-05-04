import 'patterns.dart';

const _n = matrixSize;
const _cells = _n * _n;
const _maxTrBl = (_n - 1) * 2;

List<int> _buildSnakeOrder() {
  final order = List<int>.filled(_cells, 0);
  var t = 0;
  for (var row = 0; row < _n; row += 1) {
    if (row % 2 == 0) {
      for (var col = 0; col < _n; col += 1) {
        order[rowMajorIndex(row, col)] = t;
        t += 1;
      }
    } else {
      for (var col = _n - 1; col >= 0; col -= 1) {
        order[rowMajorIndex(row, col)] = t;
        t += 1;
      }
    }
  }
  return order;
}

final List<int> _snakeOrder = _buildSnakeOrder();

List<int> _buildSpiralInwardOrder() {
  final order = List<int>.filled(_cells, 0);
  var top = 0;
  var bottom = _n - 1;
  var left = 0;
  var right = _n - 1;
  var t = 0;

  while (top <= bottom && left <= right) {
    for (var col = left; col <= right; col += 1) {
      order[rowMajorIndex(top, col)] = t;
      t += 1;
    }
    for (var row = top + 1; row <= bottom; row += 1) {
      order[rowMajorIndex(row, right)] = t;
      t += 1;
    }
    if (top < bottom) {
      for (var col = right - 1; col >= left; col -= 1) {
        order[rowMajorIndex(bottom, col)] = t;
        t += 1;
      }
    }
    if (left < right) {
      for (var row = bottom - 1; row > top; row -= 1) {
        order[rowMajorIndex(row, left)] = t;
        t += 1;
      }
    }
    top += 1;
    bottom -= 1;
    left += 1;
    right -= 1;
  }
  return order;
}

final List<int> _spiralInwardOrder = _buildSpiralInwardOrder();

final List<int> _outerRingCwOrder = () {
  final order = List<int>.filled(_cells, -1);
  const coords = [
    (0, 0),
    (0, 1),
    (0, 2),
    (0, 3),
    (0, 4),
    (1, 4),
    (2, 4),
    (3, 4),
    (4, 4),
    (4, 3),
    (4, 2),
    (4, 1),
    (4, 0),
    (3, 0),
    (2, 0),
    (1, 0),
  ];
  for (var t = 0; t < coords.length; t += 1) {
    final (row, col) = coords[t];
    order[rowMajorIndex(row, col)] = t;
  }
  return order;
}();

final List<int> _middleRingCcwOrder = () {
  final order = List<int>.filled(_cells, -1);
  const coords = [
    (1, 1),
    (2, 1),
    (3, 1),
    (3, 2),
    (3, 3),
    (2, 3),
    (1, 3),
    (1, 2),
  ];
  for (var t = 0; t < coords.length; t += 1) {
    final (row, col) = coords[t];
    order[rowMajorIndex(row, col)] = t;
  }
  return order;
}();

List<int> _buildDiagonalSnakeOrder() {
  final order = List<int>.filled(_cells, 0);
  var t = 0;

  for (var diagonal = 0; diagonal <= (_n - 1) * 2; diagonal += 1) {
    final rowStart = diagonal - (_n - 1) < 0 ? 0 : diagonal - (_n - 1);
    final rowEnd = _n - 1 < diagonal ? _n - 1 : diagonal;

    if (diagonal % 2 == 0) {
      for (var row = rowEnd; row >= rowStart; row -= 1) {
        final col = diagonal - row;
        order[rowMajorIndex(row, col)] = t;
        t += 1;
      }
    } else {
      for (var row = rowStart; row <= rowEnd; row += 1) {
        final col = diagonal - row;
        order[rowMajorIndex(row, col)] = t;
        t += 1;
      }
    }
  }
  return order;
}

final List<int> _diagonalSnakeOrder = _buildDiagonalSnakeOrder();

List<int> _buildRowWaveSnakeOrder() {
  final order = List<int>.filled(_cells, 0);
  const route = <(int, String)>[
    (0, 'up'),
    (2, 'down'),
    (1, 'up'),
    (3, 'down'),
    (2, 'up'),
    (4, 'down'),
  ];

  var t = 0;
  for (final step in route) {
    final (col, dir) = step;
    if (dir == 'up') {
      for (var row = _n - 1; row >= 0; row -= 1) {
        order[rowMajorIndex(row, col)] = t;
        t += 1;
      }
    } else {
      for (var row = 0; row < _n; row += 1) {
        order[rowMajorIndex(row, col)] = t;
        t += 1;
      }
    }
  }
  return order;
}

final List<int> _rowWaveSnakeOrder = _buildRowWaveSnakeOrder();
final int _rowWaveMaxOrder = _rowWaveSnakeOrder.isEmpty
    ? 0
    : _rowWaveSnakeOrder.reduce((a, b) => a > b ? a : b);

double trBlPathNormFromIndex(int index) {
  final coord = indexToCoord(index);
  return (coord.row + (_n - 1 - coord.col)) / _maxTrBl;
}

double snakePathNormFromIndex(int index) =>
    _snakeOrder[index] / (_cells - 1);

int snakePathOrderValue(int index) => _snakeOrder[index];

double spiralInwardNormFromIndex(int index) =>
    _spiralInwardOrder[index] / (_cells - 1);

int spiralInwardOrderValue(int index) => _spiralInwardOrder[index];

int outerRingClockwiseOrderValue(int index) => _outerRingCwOrder[index];

double outerRingClockwiseNormFromIndex(int index) {
  final order = outerRingClockwiseOrderValue(index);
  return order >= 0 ? order / 15 : 0;
}

int middleRingAntiClockwiseOrderValue(int index) =>
    _middleRingCcwOrder[index];

double middleRingAntiClockwiseNormFromIndex(int index) {
  final order = middleRingAntiClockwiseOrderValue(index);
  return order >= 0 ? order / 7 : 0;
}

int diagonalSnakeOrderValue(int index) => _diagonalSnakeOrder[index];

double diagonalSnakeNormFromIndex(int index) =>
    _diagonalSnakeOrder[index] / (_cells - 1);

int rowWaveOrderValue(int index) => _rowWaveSnakeOrder[index];

double rowWaveNormFromIndex(int index) =>
    _rowWaveMaxOrder > 0 ? rowWaveOrderValue(index) / _rowWaveMaxOrder : 0;

double colWaveNormFromIndex(int index) {
  final col = index % _n;
  return _n > 1 ? col / (_n - 1) : 0;
}

double concentricRingNormFromIndex(int index) {
  final c = _n ~/ 2;
  final coord = indexToCoord(index);
  return (coord.row - c).abs() > (coord.col - c).abs()
      ? (coord.row - c).abs() / c
      : (coord.col - c).abs() / c;
}
