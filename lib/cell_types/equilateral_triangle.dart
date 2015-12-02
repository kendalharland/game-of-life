library gol.cell_types.equilateral_triangle;

import 'package:gol/cell.dart';
import 'dart:math' show Point, PI, sin, cos;

class EquilateralTriangleNeighborStrategy implements CellNeighborStrategy {
  List<Point> computeNeighbors(Cell cell) {
    if (cell.orientation == Orientation.UP) {
      return [
        new Point(cell.x - 1, cell.y),
        new Point(cell.x + 1, cell.y),
        new Point(cell.x, cell.y + 1)
      ];
    } else {
      return [
        new Point(cell.x - 1, cell.y),
        new Point(cell.x + 1, cell.y),
        new Point(cell.x, cell.y - 1)
      ];
    }
  }
}

/// See [CellFactory].
class EquilateralTriangleCellFactory implements CellFactory {
  Cell createCell(Orientation orientation, int x, int y, int radius) {
    Point center = _computeCenter(orientation, x, y, radius);
    List<Point> vertices = _computeVertices(orientation, center, radius);
    return new Cell(orientation, center, vertices, x, y);
  }

  /// Computes the center of the cell at gol index x, y.
  ///
  /// The center's y coordinate is multiplied by 1.5 to shift adjacent rows and
  /// prevent overlapping.
  static Point _computeCenter(orientation, x, y, radius) =>
      orientation == Orientation.DOWN
          ? new Point(x * .87 + 20, y * 1.5) * radius
          : new Point(x * .87 + 20, y * 1.5 + .5) * radius;

  /// Computes the vertices of a cell with the specified [orientation], [center]
  /// and [radius].
  static List<Point> _computeVertices(orientation, center, radius) {
    List<Point> vertices;
    if (orientation == Orientation.UP) {
      vertices = <Point>[
        new Point(center.x, center.y - (radius * sin(PI / 2)).abs()), // T
        new Point(center.x - (radius * cos(7 * PI / 6)).abs(),
            center.y + (radius * sin(7 * PI / 6)).abs()), // BL
        new Point(center.x + (radius * cos(11 * PI / 6)).abs(),
            center.y + (radius * sin(11 * PI / 6)).abs()) // BR
      ];
    } else {
      vertices = <Point>[
        new Point(center.x, center.y + (radius * sin(3 * PI / 2)).abs()), // B
        new Point(center.x - (radius * cos(5 * PI / 6)).abs(),
            center.y - (radius * sin(5 * PI / 6)).abs()), // TL
        new Point(center.x + (radius * cos(13 * PI / 6)).abs(),
            center.y - (radius * sin(13 * PI / 6).abs())) // TR
      ];
    }
    return vertices;
  }
}
