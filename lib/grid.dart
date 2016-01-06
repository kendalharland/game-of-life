library gol.grid;

import 'dart:async';
import 'dart:math' show Point;

import 'package:gol/cell.dart';
import 'package:gol/grid_model.dart';
import 'package:gol/grid_click_listener.dart';

class CellChangeEvent {
  final List<Cell> cells;
  const CellChangeEvent(this.cells);
}

class Grid implements GridModel, GridClickListener {
  final GridModel _model;
  final GridClickListener _clickListener;

  Grid(int rows, int cols, SvgElement host)
      : _model = new GridModel(rows, cols),
        _clickListener = new ClickListener(host);

  Stream<CellChangeEvent> get onCellChange => _model.onCellChange;

  Stream<ClickEvent> get onCLick => _clickListener.onClick;

  Future initialize() => _model.initialize();

  void toggleCellState(int row, int col) => _model.toggleCellState(row, col);
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
