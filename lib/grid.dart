library gol.grid;

import 'dart:async';
import 'dart:math' show Point;

import 'package:gol/cell.dart';
import 'package:gol/layout.dart';

class GridConfiguration {
  final Layout layout;
  final int rows;
  final int cols;

  GridConfiguration({this.rows, this.cols, this.layout});
}

/// A collection of cells.
class Grid {
  final GridConfiguration _config;
  final _cells = <List<Cell>>[];
  final _neighbors = <Cell, List<Cell>>{};

  Grid(this._config);

  List<List<Cell>> get cells => _cells;

  /// Returns true if the grid has been initialized.
  bool get isInitialized => _cells?.isEmpty == false;

  /// Returns a future that completes when the grid has loaded all cells and
  /// finished additional computations.
  ///
  /// Repeated calls to [initialize] are a handled as no-ops.
  Future initialize() async {
    if (isInitialized) return;
    _createCells(_config.rows, _config.cols);
    //_precomputeCellNeighbors();
  }

  // Todo(kharland): This is not correct, fix.
  void clearGrid(_) {
    for (int i = 0; i < grid.cells.length; i++) {
    for (int j = 0; j < grid.cells[i].length; j++) {
        grid.cells[i][j].state = CellState.OFF;
        recolorCell(grid.cells[i][j]);
      }
    }
  }

  /// Allocates a grid of cells using the dimensions specified in the grid's
  /// configuration.
  void _createCells(int rows, int cols) {
    for (int row = 0; row < rows; row++) {
      _cells.add(<Cell>[]);
      for (int col = 0; col < cols; col++) {
        _cells[row].add(new Cell(col, row));
      }
    }
  }

  // void _precomputeCellNeighbors(CellNeighborStrategy cellNeighborStrategy) {
  //   List<Point> neighborPos;
  //   for (int i = 0; i < _cells.length; i++) {
  //     for (int j = 0; j < _cells[i].length; j++) {
  //       _neighbors[_cells[i][j]] = <Cell>[];
  //       neighborPos = cellNeighborStrategy.computeNeighbors(_cells[i][j]);
  //       neighborPos.forEach((Point neighbor) {
  //         if (0 <= neighbor.x &&
  //             neighbor.x < cols &&
  //             0 <= neighbor.y &&
  //             neighbor.y < rows) {
  //           _neighbors[_cells[i][j]].add(_cells[neighbor.y][neighbor.x]);
  //         }
  //       });
  //     }
  //   }
  // }
}
