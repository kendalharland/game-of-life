library gol.cell;

import 'dart:math' show Point, PI, sin, cos;

enum Orientation { UP, DOWN }
enum CellState { ON, OFF }

/// Represents one, stateful unit of space in a [Grid].
///
/// A cell's state is determined and set by a [Rule].
class Cell {
  final int x;
  final int y;

  CellState _state = CellState.OFF;
  CellState _previousState = CellState.OFF;

  Cell(this.x, this.y);

  CellState get state => _state;

  set state(CellState value) {
    _previousState = _state;
    _state = value;
  }

  CellState get previousState => _previousState;

  toString() => "($x,$y)";
}
