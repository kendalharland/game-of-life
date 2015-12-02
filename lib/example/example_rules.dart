library gol.example.example_rules;

import 'package:gol/rule.dart';
import 'package:gol/cell.dart';


/// If one of [cell]'s [neighbors] is on and [cell] is off, cell turns on. Else
/// cell turns off.
Rule onIfOneNeighborOn = new Rule((Cell cell, List<Cell> neighbors) {
  bool wasOn(Cell cell) => cell?.previousState == CellState.ON;
  if (neighbors.any(wasOn) && cell.state == CellState.OFF) {
    return CellState.ON;
  } else {
    return CellState.OFF;
  }
});

/// If two of [cell]'s [neighbors] is on and [cell] is off, cell turns on.
/// If three of [cell]'s [neighbors] are on, cell turns off. Else cell turns off
Rule onIf2NeighborsOn = new Rule((Cell cell, List<Cell> neighbors) {
  bool isOn(Cell cell) => cell.previousState == CellState.ON;

  if (neighbors.every(isOn)) {
    return CellState.OFF;
  }

  if (neighbors.where(isOn).length == 2 && cell.state == CellState.OFF) {
    return CellState.ON;
  }

  return CellState.OFF;
});

Rule onIf1OffIf3 = new Rule((Cell cell, List<Cell> neighbors) {
  bool isOn(Cell cell) => cell.previousState == CellState.ON;

  if (neighbors.every(isOn)) {
    return CellState.OFF;
  }

  if (neighbors.any(isOn) && cell.state == CellState.OFF) {
    return CellState.ON;
  }

  return CellState.OFF;
});