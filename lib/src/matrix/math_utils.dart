import 'dart:math' as math;

import 'patterns.dart';

const int _center = matrixSize ~/ 2;

final double _maxRadius = math.sqrt((_center * _center) + (_center * _center));

double polarAngle(int index) {
  final coord = indexToCoord(index);
  return math.atan2(coord.row - _center, coord.col - _center);
}

double normalizedRadius(int index) {
  final coord = indexToCoord(index);
  return math.sqrt(
        (coord.row - _center) * (coord.row - _center) +
            (coord.col - _center) * (coord.col - _center),
      ) /
      _maxRadius;
}

double manhattanDistance(int index) {
  final coord = indexToCoord(index);
  return ((coord.row - _center).abs() + (coord.col - _center).abs()).toDouble();
}

double harmonicPhase(int row, int col, double a, double b) {
  return math.sin((row + 1) * a + (col + 1) * b);
}

({double x, double y, double phase}) lissajousOffset(
  int row,
  int col, [
  double amplitude = 2.25,
]) {
  final x = math.sin((row + 1) * 1.15 + (col + 1) * 2.2) * amplitude;
  final y = math.cos((row + 1) * 2.45 + (col + 1) * 0.95) * amplitude;
  final phase = math.sin((row + 1) * 0.7 + (col + 1) * 1.1).abs();
  return (x: x, y: y, phase: phase);
}

({double x, double y, double phase}) spiralOffset(
  double angle,
  double radiusNormalizedValue, [
  double amplitude = 2.8,
]) {
  final spin = angle + radiusNormalizedValue * math.pi * 2.1;
  final radius = radiusNormalizedValue * amplitude;
  final x = math.cos(spin) * radius;
  final y = math.sin(spin) * radius;
  final phase = math.sin(spin * 0.5).abs();
  return (x: x, y: y, phase: phase);
}

bool isPrime(int value) {
  if (value <= 1) return false;
  if (value == 2) return true;
  if (value % 2 == 0) return false;

  final limit = math.sqrt(value).floor();
  for (var divisor = 3; divisor <= limit; divisor += 2) {
    if (value % divisor == 0) return false;
  }
  return true;
}
