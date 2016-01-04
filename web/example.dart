import 'dart:async';
import 'dart:html';
import 'dart:svg' hide Point;

import 'package:gol/cell.dart';
import 'package:gol/cell_renderer.dart';
import 'package:gol/grid.dart';
import 'package:gol/rule.dart';
import 'package:gol/layouts/equilateral_triangle.dart';
//import 'package:gol/layouts/square.dart';
import 'package:gol/example/example_rules.dart';

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
        data: key, value: key, selected: rules[key] == selectedRule));
  });
  rulesHost.onChange.listen((e) {
    String ruleKey = (e.target as SelectElement).selectedOptions.first.value;
    selectedRule = rules[ruleKey];
  });
}

void step(_) {
  for (int i = 0; i < grid.cells.length; i++) {
    for (int j = 0; j < grid.cells[i].length; j++) {
      grid.cells[i][j].state = grid.cells[i][j].state;
    }
  }
  run();
}

void run() {
  for (int i = 0; i < grid.cells.length; i++) {
    for (int j = 0; j < grid.cells[i].length; j++) {
      Cell cell = grid.cells[i][j];
      cell.state = selectedRule.computeState(cell, grid.neighbors[cell]);
      recolorCell(cell);
    }
  }
  ;
}

void timeRun(_) {
  int maxRunTime = -1;
  Stopwatch s = new Stopwatch();

  if (runTimer != null) {
    runTimer.cancel();
  }

  for (int i = 0; i < grid.cells.length; i++) {
    for (int j = 0; j < grid.cells[i].length; j++) {
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
  
  if (cell == null) return;

  cell.state = cell.state == CellState.ON ? CellState.OFF : CellState.ON;
  recolorCell(cell);
}

void attachClickListeners(Element host) {
  querySelector("#run").onClick.listen(timeRun);
  querySelector("#clear").onClick.listen(clearGrid);
  querySelector("#stop").onClick.listen((_) => runTimer?.cancel());
  querySelector("#step").onClick.listen(step);
}

void main() {
  final layout = new EquilateralTriangleLayout(cellRadius: 10);
  final config = new GridConfiguration(rows: 20, cols: 20, layout: layout);
  final grid = new Grid(config);
  final host = querySelector("#grid") as SvgElement;
  final gridRenderer = new GridRenderer(host: host, layout: layout);

  attachClickListeners(host);
  //loadRules();

  host.onClick.listen(swapCellState);
  print("Initializing grid...");
  grid.initialize().then((_) {
    print("Rendering grid...");
    gridRenderer.renderGrid(grid);
  });
}
