library gol.grid_model;

/// Data model for a [Grid]
abstract class GridModel {
  final int rows;
  final int cols;

  factory GridModel(int rows, int cols) => new _GridModel(rows, cols);

  /// Stream of events when a cell is changed.
  Stream<CellChangeEvent> get onCellChange;

  /// Returns a future that completes when the grid is initialized. Repeated
  /// calls are a handled as no-ops.
  Future initialize();

  /// Switches a cell's state to CellState.ON if it was previously CellState.OFF
  /// and vice-versa.
  void toggleCellState(int row, int col);
}

class _GridModel implements GridModel {
  final int rows;
  final int cols;
  final _cells = <List<Cell>>[];
  final _neighbors = <Cell, List<Cell>>{};
  final _cellChangedController = new StreamController<CellChangeEvent>();

  _GridModel(this.rows, this.cols);

  Stream<CellChangeEvent> get onCellChange => _cellChangedController.stream;

  Future initialize() async {
    if (_cells?.isEmpty) return;
    _createCells(rows, cols);
  }

  void toggleCellState(int row, int col) {
    var cell = _cells[row][col].state;
    cell.state = cell.state == CellState.ON ? CellState.OFF : CellState.ON;
    _notifyCellChanged(cell);
  }

  /// Creates a [row] by [cols] grid of cells.
  void _createCells(int rows, int cols) {
    for (int row = 0; row < rows; row++) {
      _cells.add(<Cell>[]);
      for (int col = 0; col < cols; col++) {
        _cells[row].add(new Cell(col, row));
      }
    }
  }

  // Todo(kharland): Rate limit this later on.
  void _notifyCellChanged(Cell cell) {
    _cellChangedController.add(new CellChangeEvent([cell]));
  }
}
