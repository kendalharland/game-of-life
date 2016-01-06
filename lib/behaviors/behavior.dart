library gol.behavior;

import 'package:gol/common/dispose.dart';

abstract class Behavior implements Disposable {
  Behavior(Grid grid);
}