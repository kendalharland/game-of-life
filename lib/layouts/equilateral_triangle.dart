library gol.layouts.equilateral_triangle_layout;

import 'dart:math' show Point, PI, sin, cos;

import 'package:gol/cell.dart';
import 'package:gol/layout.dart';

/// A [Layout] implementation for equilateral triangles.
class EquilateralTriangleLayout implements Layout {
  final int cellRadius;
  final Point _origin;

  EquilateralTriangleLayout({this.cellRadius}) :
    _origin = new Point(cellRadius, cellRadius);

  Orientation getOrientation(int row, int col) =>
      (row % 2 == col % 2) ? Orientation.DOWN : Orientation.UP;

  Point getCenter(int row, int col) => _origin +
      (getOrientation(row, col) == Orientation.DOWN
          ? new Point(col * .87 + 20, row * 1.5) * cellRadius
          : new Point(col * .87 + 20, row * 1.5 + .5) * cellRadius);

  List<Point> getVertices(int row, int col) {
    List<Point> vertices;
    var center = getCenter(row, col);
    var x1, y1, x2, y2, x3, y3;

    if (getOrientation(row, col) == Orientation.UP) {
      // Top.
      x1 = center.x;
      y1 = center.y - (cellRadius * sin(PI / 2)).abs();
      // Bottom left.
      x2 = center.x - (cellRadius * cos(7 * PI / 6)).abs();
      y2 = center.y + (cellRadius * sin(7 * PI / 6)).abs();
      // Bottom right.
      x3 = center.x + (cellRadius * cos(11 * PI / 6)).abs();
      y3 = center.y + (cellRadius * sin(11 * PI / 6)).abs();
    } else {
      // Bottom
      x1 = center.x;
      y1 = center.y + (cellRadius * sin(3 * PI / 2)).abs();
      // Top left.
      x2 = center.x - (cellRadius * cos(5 * PI / 6)).abs();
      y2 = center.y - (cellRadius * sin(5 * PI / 6)).abs();
      // Top right.
      x3 = center.x + (cellRadius * cos(13 * PI / 6)).abs();
      y3 = center.y - (cellRadius * sin(13 * PI / 6)).abs();
    }

    return [new Point(x1, y1), new Point(x2, y2), new Point(x3, y3)]
        .map((point) => point + _origin);
  }

  // Todo(kjharland): cache neighbor computations?
  List<Point> getNeighbors(Cell cell) {
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
