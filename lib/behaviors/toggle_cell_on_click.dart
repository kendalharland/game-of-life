library gol.behavior.toggle_cell_on_click;

import 'dart:async';

import 'package:gol/behavior.dart';

class ToggleCellOnClick implements Behavior {
  StreamSubscription _subscription;

  ToggleCellOnClick(Grid grid) {
    _subscription = grid.onCellClicked.listen((ClickEvent e) {
      if (e.target is Cell) {
        grid.toggleCellState(cell);
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}