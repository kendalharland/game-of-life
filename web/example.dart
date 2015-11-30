import 'dart:async';
import 'dart:html';
import 'dart:math' show Point, cos, sin, PI;
import 'dart:svg' hide Point;

enum Orientation {UP, DOWN}
enum CellState {ON, OFF}

class Cell {
  final Orientation orientation;
  final Point center;
  final int x;
  final int y;
  final List<Point> vertices;
  CellState _state = CellState.OFF;
  CellState _previousState = CellState.OFF;

  toString() => "($x,$y)";

  CellState get state => _state;
  set state(CellState value) {
    _previousState = _state;
    _state = value;
  }

  CellState get previousState => _previousState;
  set previousState(CellState value) {
    _previousState = value;
  }

  Cell(this.orientation, this.center, this.vertices, this.x, this.y);
}

abstract class CellFactory {
  /// Constructs and returns a cell with the specified dimensions, position and
  /// orientation.
  Cell createCell(Orientation orientation, int x, int y, int radius);
}

/// Constructs a [Cell] as an equilateral triangle.
class EquilateralTriangleCellFactory implements CellFactory {
  /// see [CellFactory].createCell
  Cell createCell(Orientation orientation, int x, int y, int radius) {
    Point center = _computeCenter(orientation, x, y, radius);
    List<Point> vertices = _computeVertices(orientation, center, radius);
    return new Cell(orientation, center, vertices, x, y);
  }

  /// Computes the center of the cell at grid index x, y.
  ///
  /// The center's y coordinate is multiplied by 1.5 to shift adjacent rows and
  /// prevent overlapping.
  static Point _computeCenter(orientation, x, y, radius) =>
      orientation == Orientation.DOWN
        ? new Point(x * .87, y * 1.5) * radius
        : new Point(x * .87, y * 1.5 + .5) * radius;

  /// Computes the vertices of a cell with the specified [orientation], [center]
  /// and [radius].
  static List<Point> _computeVertices(orientation, center, radius) {
    List<Point> vertices;
    if (orientation == Orientation.UP) {
      vertices = <Point>[
        new Point(center.x,
                  center.y - (radius * sin(PI / 2)).abs()), // T
        new Point(center.x - (radius * cos(7 * PI / 6)).abs(),
                  center.y + (radius * sin(7 * PI / 6)).abs()), // BL
        new Point(center.x + (radius * cos(11 * PI / 6)).abs(),
                  center.y + (radius * sin(11 * PI / 6)).abs()) // BR
      ];
    } else {
      vertices = <Point>[
        new Point(center.x,
                  center.y + (radius * sin(3 * PI / 2)).abs()), // B
        new Point(center.x - (radius * cos(5 * PI / 6)).abs(),
                  center.y - (radius * sin(5 * PI / 6)).abs()), // TL
        new Point(center.x + (radius * cos(13 * PI / 6)).abs(),
                  center.y - (radius * sin(13 * PI / 6).abs())) // TR
      ];
    }
    return vertices;
  }
}

/// A collection that maps cartesian coordinates to grid cells.
class Grid {
  final int _rows;
  final int _cols;
  final num cellRadius;
  Map<Point, Cell> _cells = <Point, Cell>{};

  /// Constructor to initialize an [m] x [n] grid of cells.
  Grid(this._rows, this._cols, this.cellRadius, CellFactory cellFactory) {
    Orientation orientation = Orientation.DOWN;
    for (int y=1; y < _rows; y++) {
      for (int x=1; x < _cols; x++) {
        orientation = orientation == Orientation.UP
            ? Orientation.DOWN
            : Orientation.UP;
        _cells.putIfAbsent(new Point(x, y), () =>
          cellFactory.createCell(orientation, x, y, cellRadius));
      }
    }
  }

  get cells => _cells.values;

  /// Returns the cell corresponding to [index] or throws an exception of [index]
  /// is not in the grid.
  /// Todo(kjharland): this could return a Grid accessor so that the consumer
  /// could access like so:
  ///   grid[x][y]
  /// instead of:
  ///   grid[point];
  Cell operator[](Point index) => _cells[index];
}

void drawCellCenter(Cell cell) {
  var center = cell.center;
  var c = new SvgElement.tag('circle')
    ..setAttribute("r", '2')
    ..setAttribute("stroke", "red")
    ..setAttribute("fill", "transparent")
    ..setAttribute("cx", "${center.x}")
    ..setAttribute("cy", "${center.y}");
  host.append(c);
}

void drawCell(Cell cell) {
  var vertices = cell.vertices;
  var d = vertices.fold("M${vertices.last.x} ${vertices.last.y}",
      (v, next) => v + " L${next.x} ${next.y}");
  var p = new PathElement()
    ..setAttribute("class", "hexoutline")
    ..setAttribute("d", d)
    ..setAttribute("fill", cell.state == CellState.OFF ? "white" : "black")
    ..setAttribute("stroke", "Gray");
  host.append(p);
  cellToElement[cell] = p;
  elementToCell[p] = cell;
}

void recolorCell(Cell cell) {
  cellToElement[cell].setAttribute("fill", cell.state == CellState.OFF ? "white" : "black");
}

//////////////////

/// Function that computes the state of [cell]
typedef CellState StateComputation(Grid grid, Cell cell, NeighborStrategy neighborStrategy);

/// Interface for computing the state of a cell.
class Rule {
  final StateComputation computeState;
  const Rule(this.computeState);
}

/// Computes the neighbors of a cell in a grid.
abstract class NeighborStrategy {
  List<Cell> computeNeighbors(Grid grid, Cell cell);
}

class EquilateralTriangleNeighborStrategy implements NeighborStrategy {
  List<Cell> computeNeighbors(Grid grid, Cell cell) {
    if (cell.orientation == Orientation.UP) {
      return [
        grid[new Point(cell.x - 1, cell.y)],
        grid[new Point(cell.x + 1, cell.y)],
        grid[new Point(cell.x, cell.y + 1)]
      ];
    } else {
      return [
        grid[new Point(cell.x - 1, cell.y)],
        grid[new Point(cell.x + 1, cell.y)],
        grid[new Point(cell.x, cell.y - 1)]
      ];
    }
  }
}

//////////////////

Element host;
Grid grid;
int rows;
int cols;
Timer runTimer;
int maxRunTime;
Rule rule;
Stopwatch s = new Stopwatch()..start();
final Map<Cell, Element> cellToElement = <Cell, Element>{};
final Map<Element, Cell> elementToCell = <Element, Cell>{};
final NeighborStrategy neighborStrategy = new EquilateralTriangleNeighborStrategy();
final Map<Cell, List<Cell>> cellToNeighbors = <Cell, List<Cell>>{};

void run(_) {
  grid.cells.forEach((Cell cell) {
    cell.state = rule.computeState(grid, cell, neighborStrategy);
    recolorCell(cell);
  });
}

void swapCellState(MouseEvent e) {
  Cell cell = elementToCell[e.target];
  cell.state = cell.state == CellState.ON ? CellState.OFF : CellState.ON;
  cell.previousState = cell.state;

  (e.target as Element).remove();
  elementToCell.remove(e.target);
  cellToElement.remove(cell);

  drawCell(cell);
}


void main() {
  rows = 50;
  cols = 50;
  const int interval = 10;
  int cellRadius = 10;
  grid = new Grid(rows, cols, cellRadius, new EquilateralTriangleCellFactory());

  host = querySelector("#grid");
  rule = new Rule((Grid grid, Cell cell, NeighborStrategy neighborStrategy) {
    var neighbors = cellToNeighbors[cell];
    if (neighbors.any((Cell nbr) => nbr != null && nbr.previousState == CellState.ON) &&
        cell.state == CellState.OFF) {
      return CellState.ON;
    } else {
      return CellState.OFF;
    }
  });

  host.onClick.listen((e) {
    var cell = elementToCell[e.target];
    print("(${cell.x}, ${cell.y})");
    print(cellToNeighbors[cell]);
    swapCellState(e);
  });

  querySelector("#run").onClick.listen((e) {
    if (runTimer != null) runTimer.cancel();
    run(null);

    runTimer = new Timer.periodic(const Duration(milliseconds: interval), (_) {
      s.start();

      run(null);

      s.stop();
      if (maxRunTime == null || s.elapsedMilliseconds > maxRunTime) {
        maxRunTime = s.elapsedMilliseconds;
        print('run: ${maxRunTime}ms');
      }
      s.reset();
    });
  });

  querySelector("#stop").onClick.listen((_) {
    if (runTimer != null) runTimer.cancel();
  });

  querySelector("#step").onClick.listen((_) => run(null));

  if (cellToNeighbors.isEmpty) {
    grid.cells.forEach((cell) {
      cellToNeighbors[cell] = neighborStrategy.computeNeighbors(grid, cell);
    });
  }
  grid.cells.forEach(drawCell);
}