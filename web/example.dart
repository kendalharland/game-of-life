import 'dart:async';
import 'dart:html';
import 'dart:svg' hide Point;

import 'package:gol/cell.dart';
import 'package:gol/grid.dart';
import 'package:gol/rule.dart';
import 'package:gol/cell_types/equilateral_triangle.dart';
import 'package:gol/example/example_rules.dart';

// Globals because I r gud programar.
Element host;
Grid grid;
Duration delay = const Duration(milliseconds: 30);
Timer runTimer;
final Map<Cell, Element> cellToElement = <Cell, Element>{};
final Map<Element, Cell> elementToCell = <Element, Cell>{};

/// The set of rules
Map<Rule> rules = <Rule>{
  'onIf1OffIf3': onIf1OffIf3,
  'onIf2NeighborsOn': onIf2NeighborsOn,
  'onIfOneNeighborOn': onIfOneNeighborOn
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
      drawCell(grid.cells[i][j]);
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
  (e.target as Element).remove();
  elementToCell.remove(e.target);
  cellToElement.remove(cell);
  drawCell(cell);
}

void main() {
  const int rows = 80;
  const int cols = 101;
  const int cellRadius = 5;
  host = querySelector("#grid");

  CellNeighborStrategy cellNeighborStrategy =
      new EquilateralTriangleNeighborStrategy();
  CellFactory cellFactory = new EquilateralTriangleCellFactory();
  grid = new Grid(rows, cols, cellRadius, cellFactory, cellNeighborStrategy);

  host.onClick.listen(swapCellState);

  // Set up control panel
  querySelector("#run").onClick.listen(timeRun);
  querySelector("#clear").onClick.listen(clearGrid);
  querySelector("#stop").onClick.listen((_) => runTimer?.cancel());
  querySelector("#step").onClick.listen(step);
  loadRules();

  // Load grid
  print("Computing grid...");
  grid.init().then((_) {
    print("Rendering grid...");
    for (int i=0; i < grid.cells.length; i++) {
      for (int j=0; j < grid.cells[i].length; j++) {
        drawCell(grid.cells[i][j]);
      }
    }
  });
}
