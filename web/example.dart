import 'dart:async';
import 'dart:html';
import 'dart:svg' hide Point;

import 'package:gol/cell.dart';
import 'package:gol/grid_renderer.dart';
import 'package:gol/grid.dart';
import 'package:gol/behaviors/toggle_cell_on_click.dart';
import 'package:gol/rule.dart';
import 'package:gol/layouts/equilateral_triangle.dart';
//import 'package:gol/layouts/square.dart';
import 'package:gol/example/example_rules.dart';


/// Todo(kj)
Timer runTimer;
Rule selectedRule = rules.values.first;

/// The set of rules
Map<String, Rule> rules = <String, Rule>{
  'onIf1OnAndOff': onIf1OnAndOff,
  'onIf2On': onIf2On,
  'onIf1OnOffIf3On': onIf1OnOffIf3On,
};


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


/// Todo(kjharland): Some of these callbacks need to be moved to a class
void loadControlPanel() {
  querySelector("#run").onClick.listen(timeRun);
  querySelector("#clear").onClick.listen(clearGrid);
  querySelector("#stop").onClick.listen((_) => runTimer?.cancel());
  querySelector("#step").onClick.listen(step);
}

void loadRules() {
  final rulesHost = document.querySelector("#rules");
  
  rules.forEach((key, value) {
    rulesHost.append(new OptionElement(
        data: key, value: key, selected: rules[key] == selectedRule));
  });
  
  rulesHost.onChange.listen((e) {
    final select = e.target as SelectElement;
    selectedRule = rules[select.selectedOptions.first.value];
  });
}

void bootstrap() {
  loadControlPanel();
  loadRules();
}

Future main() async {
  final host = querySelector("#grid") as SvgElement;
  final grid = new Grid(20, 20, host);
  final gridRenderer =
      new GridRenderer(host, new EquilateralTriangleLayout(cellRadius: 10));

  await grid.initialize();
  await gridRenderer.renderGrid(grid);
  grid.addBehavior(new ToggleCellOnClick());

  bootstrap();
}
