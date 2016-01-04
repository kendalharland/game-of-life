library gol.layout;

/// Controls how a [Grid] of cells will be rendered.
abstract class Layout {
  /// The radius of each cell in a [Grid].
  final int cellRadius;

  Layout({this.cellRadius, this.origin});

  /// Returns the orientation of the cell at [row] and [col].
  Orientation getOrientation(int row, int col);

  /// Returns the neighbors of the cell at [row] and [col].
  List<Point> getNeighbors(int row, int col);

  /// Computes the vertices of a cell circumscribed with [radius] and [center].
  List<Point> getVertices(Point center, num radius);

  /// Computes the center of the cell at [row] and [col] with [radius].
  num getCenter(int row, int col, int radius, [Orientation orientation]);
}
