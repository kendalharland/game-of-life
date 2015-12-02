library gol.grid;

import 'dart:async';
import 'dart:math' show Point;

import 'package:gol/cell.dart';

/// A collection that maps cartesian coordinates to gol cells.
class Grid {
  final int rows;
  final int cols;
  final num cellRadius;

  List<List<Cell>> _cells = <List<Cell>>[];
  Map<Cell, List> _neighbors = <Cell, List<Cell>>{};

  /// Constructor to initialize a [rows] x [col] grid of cells.
  Grid(this.rows, this.cols, this.cellRadius);

  /// Returns a future that completes when the grid is fully initialized.
  Future init(
      CellFactory cellFactory,
      CellNeighborStrategy cellNeighborStrategy) async {
    _createCells(cellFactory);
    _computeCellNeighbors(cellNeighborStrategy);
  }

  get cells => _cells;

  get neighbors => _neighbors;

  void _createCells(CellFactory cellFactory) {
    Orientation orientation = Orientation.DOWN;
    for (int y=0; y < rows; y++) {
      _cells.add(<Cell>[]);
      for (int x=0; x < cols; x++) {
        orientation =
            orientation == Orientation.UP ? Orientation.DOWN : Orientation.UP;
        _cells[y].add(cellFactory.createCell(orientation, x, y, cellRadius));
        Cell cell = _cells[y][x];
      }
    }
  }

  void _computeCellNeighbors(CellNeighborStrategy cellNeighborStrategy) {
    List<Point> neighborPos;
    for (int i = 0; i < _cells.length; i++) {
      for (int j = 0; j < _cells[i].length; j++) {
        _neighbors[_cells[i][j]] = <Cell>[];
        neighborPos = cellNeighborStrategy.computeNeighbors(_cells[i][j]);
        neighborPos.forEach((Point neighbor) {
          if (0 <= neighbor.x && neighbor.x < cols &&
              0 <= neighbor.y && neighbor.y < rows) {
            _neighbors[_cells[i][j]].add(_cells[neighbor.y][neighbor.x]);
          }
        });
      }
    }
  }
}
