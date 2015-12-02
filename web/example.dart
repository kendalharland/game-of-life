import 'dart:async';
import 'dart:html';
import 'dart:svg' hide Point;

import 'package:gol/cell.dart';
import 'package:gol/grid.dart';
import 'package:gol/rule.dart';
import 'package:gol/cell_types/equilateral_triangle.dart';
import 'package:gol/cell_types/square.dart';
import 'package:gol/example/example_rules.dart';

// Globals because I r gud programar.
SvgElement host;
Point origin;
Grid grid;
Duration delay = const Duration(milliseconds: 30);
Timer runTimer;
final Map<Cell, Element> cellToElement = <Cell, Element>{};
final Map<Element, Cell> elementToCell = <Element, Cell>{};

/// The set of rules
Map<String, Rule> rules = <String, Rule>{
  'onIf1OnAndOff': onIf1OnAndOff,
  'onIf2On': onIf2On,
  'onIf1OnOffIf3On': onIf1OnOffIf3On,
};
Rule selectedRule = rules.values.first;

void loadRules() {
  Element rulesHost = document.querySelector("#rules");
  rules.forEach((key, value) {
    rulesHost.append(new OptionElement(
        data: key,
        value: key,
        selected: rules[key] == selectedRule));
  });
  rulesHost.onChange.listen((e) {
    String ruleKey = (e.target as SelectElement).selectedOptions.first.value;
    selectedRule = rules[ruleKey];
  });
}

void clearGrid(_) {
  for (int i=0; i < grid.cells.length; i++) {
    for (int j=0; j < grid.cells[i].length; j++) {
      grid.cells[i][j].state = CellState.OFF;
      recolorCell(grid.cells[i][j]);
    }
  }
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

void drawCell(Cell cell, CellFactory cellFactory) {
  var v = cellFactory
      .computeVertices(cell.center, grid.cellRadius)
      .map((Point vertex) => vertex += origin);
  var d = v.fold("M${v.last.x} ${v.last.y}",
      (vs, next) => vs + " L${next.x} ${next.y}");

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
  cellToElement[cell]
      .setAttribute("fill", cell.state == CellState.OFF ? "white" : "black");
}

void step(_) {
  for (int i=0; i < grid.cells.length; i++) {
    for (int j=0; j < grid.cells[i].length; j++) {
      grid.cells[i][j].state = grid.cells[i][j].state;
    }
  }
  run();
}

void run() {
  for (int i=0; i < grid.cells.length; i++) {
    for (int j=0; j < grid.cells[i].length; j++) {
      Cell cell = grid.cells[i][j];
      cell.state = selectedRule.computeState(cell, grid.neighbors[cell]);
      recolorCell(cell);
    }
  };
}

void timeRun(_) {
  int maxRunTime = -1;
  Stopwatch s = new Stopwatch();

  if (runTimer != null) {
    runTimer.cancel();
  }

  for (int i=0; i < grid.cells.length; i++) {
    for (int j=0; j < grid.cells[i].length; j++) {
      grid.cells[i][j].state = grid.cells[i][j].state;
    }
  }

  runTimer = new Timer.periodic(delay, (_) {
    s.start();
    run();
    s.stop();
    if (s.elapsedMilliseconds > maxRunTime) {
      maxRunTime = s.elapsedMilliseconds;
      print('run: ${maxRunTime}ms');
    }
    s.reset();
  });
}

void swapCellState(MouseEvent e) {
  Cell cell = elementToCell[e.target];

  if (cell == null) {
    return;
  }

  cell.state = cell.state == CellState.ON ? CellState.OFF : CellState.ON;
  recolorCell(cell);
}

void main() {
  const int rows = 80;
  const int cols = 100;
  const int cellRadius = 5;
  origin = new Point(cellRadius, cellRadius);
  host = querySelector("#grid") as SvgElement;

  CellNeighborStrategy cellNeighborStrategy = new SquareNeighborStrategy();
  CellFactory cellFactory = new SquareCellFactory();
  grid = new Grid(rows, cols, cellRadius);

  host.onClick.listen(swapCellState);

  // Set up control panel
  querySelector("#run").onClick.listen(timeRun);
  querySelector("#clear").onClick.listen(clearGrid);
  querySelector("#stop").onClick.listen((_) => runTimer?.cancel());
  querySelector("#step").onClick.listen(step);
  loadRules();

  // Load grid
  print("Computing grid...");
  grid.init(cellFactory, cellNeighborStrategy).then((_) {
    print("Rendering grid...");
    for (int i=0; i < grid.cells.length; i++) {
      for (int j=0; j < grid.cells[i].length; j++) {
        drawCell(grid.cells[i][j], cellFactory);
      }
    }
  });
}
