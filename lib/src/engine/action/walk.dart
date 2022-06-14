import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/action/action.dart';

class WalkAction extends Action {
  final Direction dir;

  WalkAction(super.actor, this.dir);

  bool onPerform() {
    var pos = actor.pos + dir;

    return true;
  }
}