library gol.grid_click_listener;


class ClickEvent {
  final target;
  ClickEvent(this.target);
}

abstract class GridClickListener {
  /// Stream of events when the grid is clicked
  Stream<ClickEvent> get onClick;
}