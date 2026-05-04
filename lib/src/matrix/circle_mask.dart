const _cornerCoords = {
  (0, 0),
  (0, 4),
  (4, 0),
  (4, 4),
};

/// Returns true for the 21 cells of a 5×5 grid that fall within a circle
/// inscribed inside the square (excludes the 4 corners).
bool isWithinCircularMask(int row, int col) =>
    !_cornerCoords.contains((row, col));
