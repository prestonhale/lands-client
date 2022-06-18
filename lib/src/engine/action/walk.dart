import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/action/action.dart';

class WalkAction extends Action {
  final Direction dir;

  WalkAction(super.actor, this.dir);

  @override
  ActionResult onPerform() {
    // If we're already facing a direction, move that direction.
    if (actor.direction == dir) {
      var pos = actor.pos + dir;

      if (!actor.canOccupy(pos)) {
        return ActionResult.failure;
      }
      actor.pos = pos;

      // Otherwise, change our direction
    } else {
      actor.direction = dir;
    }

    return ActionResult.success;
  }
}
