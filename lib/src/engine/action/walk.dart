import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/action/action.dart';

class WalkAction extends Action {
  final Direction dir;

  WalkAction(super.actor, this.dir);

  @override
  ActionResult onPerform() {
    actor.direction = Direction.none;

    var pos = actor.pos + dir;

    if (!actor.canOccupy(pos)) {
      return ActionResult.failure;
    }
    actor.pos = pos;

    return ActionResult.success;
  }
}
