library gol.rule;

import 'package:gol/cell.dart';

/// Function that computes the state of [cell] from [grid]
typedef CellState StateComputation(Cell cell, List<Cell> neighbors);

/// Interface for computing the state of a cell.
class Rule {
  final StateComputation computeState;
  const Rule(this.computeState);
}
