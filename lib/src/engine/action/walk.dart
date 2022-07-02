import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/action/action.dart';

class WalkAction extends Action {
  final Direction dir;

  WalkAction(super.actor, this.dir);

  @override
  ActionResult onPerform() {
    actor.direction = Direction.none;

    var pos = actor.pos + dir;

    // If we bump a resource of ANY KIND, stop moving and target it.
    // This currently means that ALL resources are impassable.
    var resource = actor.game.stage.resourceAt(pos);
    if (resource != null) {
      actor.target = resource;
      return ActionResult.success;
    }
    
    if (!actor.canOccupy(pos)) {
      return ActionResult.failure;
    }

    actor.target = null;
    actor.pos = pos;

    return ActionResult.success;
  }
}
