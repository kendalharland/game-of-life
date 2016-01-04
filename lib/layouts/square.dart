library gol.layouts.square;

import 'dart:math' show Point, PI, sin, cos;

import 'package:gol/cell.dart';

/// [CellNeighborStrategy] that returns the coordinates of the gird neighbors of
/// a square.
class SquareNeighborStrategy implements CellNeighborStrategy {
  List<Point> computeNeighbors(Cell cell) => <Point>[
        new Point(cell.x, cell.y - 1), // T
        new Point(cell.x + 1, cell.y), // R
        new Point(cell.x, cell.y + 1), // B
        new Point(cell.x - 1, cell.y), // L
      ];
}

/// See [CellFactory].
class SquareCellFactory implements CellFactory {
  // Treating orientation as garbage because squares are only oriented at 90deg
  // angles.  Todo(kjharland): Refactor orientation out of global namespace.
  Cell createCell(_, int x, int y, int radius) {
    Point center = _computeCenter(x, y, radius);
    return new Cell(null, center, x, y);
  }

  List<Point> computeVertices(center, radius) => [
        new Point(center.x + (cos(PI / 4) * radius).abs(),
            center.y - (sin(PI / 4) * radius).abs()),
        new Point(center.x - (cos(3 * PI / 4) * radius).abs(),
            center.y - (sin(3 * PI / 4) * radius).abs()),
        new Point(center.x - (cos(5 * PI / 4) * radius).abs(),
            center.y + (sin(5 * PI / 4) * radius).abs()),
        new Point(center.x + (cos(7 * PI / 4) * radius).abs(),
            center.y + (sin(7 * PI / 4) * radius).abs()),
      ];

  // Todo(kjharland):
  // 1. Spacing sucks because shapes are circumscribed rather than inscribed.
  // 2. Spacing also sucks because the cell's border is not accounted for.
  static Point _computeCenter(x, y, radius) => new Point(x, y) * 1.5 * radius;
}
