library gol.cell_renderer;

import 'dart:html';
import 'dart:svg' hide Point;

import 'package:gol/cell.dart';

/// Draws a cell inside A host element.
class CellRenderer {
  final Layout layout;
  final SvgElement host;

  final _cellToElement = <Cell, Element>{};
  final _elementToCell = <Element, Cell>{};

  CellRenderer({this.host, this.layout});

  /// Draws [cell] inside [host].
  void renderCell(Cell cell) {
    if (_cellExists(cell)) {
      _updateRenderedCell(cell);
    } else {
      _renderNewCell(cell);
    }
  }

  /// Draws the center of [cell] inside [host].
  void renderCellCenter(Cell cell) {
    var center = new SvgElement.tag('circle')
      ..setAttribute("r", '1')
      ..setAttribute("stroke", "red")
      ..setAttribute("fill", "transparent")
      ..setAttribute("cx", "${cell.center.x}")
      ..setAttribute("cy", "${cell.center.y}");
    host.append(center);
  }

  void _getCellColor(Cell cell) =>
      cell.state == CellState.OFF ? "white" : "black";

  bool _cellExists(Cell cell) => _cellToElement.containsKey(cell);

  void _linkCellToElement(Cell cell, Element element) {
    _cellToElement[cell] = element;
    _elementToCell[element] = cell;
  }

  void _renderNewCell(Cell cell) {
    var vertices = layout.getVertices(cell.x, cell.y);
    var path = new PathElement();
    var d = vertices.fold("M${vertices.last.x} ${vertices.last.y}",
        (ds, vertex) => "$ds L${vertex.x} ${vertex.y}");

    path
      ..setAttribute("class", "hexoutline")
      ..setAttribute("d", d)
      ..setAttribute("stroke", "Gray");
    host.append(path);
    _linkCellToElement(cell, path);
    _updateRenderedCell(cell);
  }

  void _updateRenderedCell(Cell cell) {
    if (!_cellExists(cell)) {
      throw "cannot updated non-existent cell $cell";
    }
    _cellToElement[cell].setAttribute("fill", _getCellColor(cell));
  }
}

/// Draws a grid inside a host element.
class GridRenderer {
  CellRenderer _cellRenderer;

  GridRenderer({SvgElement host, Layout layout}) {
    _cellRenderer = new CellRenderer(host: host, layout: layout);
  }

  Future renderGrid(Grid grid) async {
    grid.cells.forEach((row) {
      row.forEach(_cellRenderer.renderCell);
    });
  }
}
