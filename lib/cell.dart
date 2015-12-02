library gol.cell;

import 'dart:math' show Point, PI, sin, cos;

enum Orientation { UP, DOWN }
enum CellState { ON, OFF }

/// Represents one, stateful unit of space in a [Grid].
///
/// A cell's state is determined and set by a [Rule].
class Cell {
  final Orientation orientation;
  final Point center;
  final int x;
  final int y;
  CellState _state = CellState.OFF;
  CellState _previousState = CellState.OFF;

  toString() => "($x,$y)";

  CellState get state => _state;
  set state(CellState value) {
    _previousState = _state;
    _state = value;
  }

  CellState get previousState => _previousState;

  Cell(this.orientation, this.center, this.x, this.y);
}

/// Produces [Cell] instances and handles computation such as the cell's center
/// and edge coordinates.
abstract class CellFactory {
  /// Constructs and returns a cell with the specified dimensions, position and
  /// orientation.
  Cell createCell(Orientation orientation, int x, int y, int radius);

  /// Computes and returns the vertices of a cell circumscribed in a circle
  /// with [radius] and [center].
  List<Point> computeVertices(Point center, num radius);
}

/// Computes the grid coordinates of a cell's neighbors.
abstract class CellNeighborStrategy {
  List<Point> computeNeighbors(Cell cell);
}
