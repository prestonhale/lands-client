import 'package:lands/src/engine/player/player.dart';
import 'package:lands/src/engine/stage/resource.dart';
import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/action/action.dart';

class InteractAction extends Action {
  Player _player;

  InteractAction(super.actor) : _player = actor as Player;

  @override
  ActionResult onPerform() {
    // Only player's can use the interact action.
    var player = actor as Player;

    // If we're targeting a resource, attempt to interact with it.
    late ActionResult result;
    var target = player.target;
    if (target != null) {
      // TODO: Resources need to be able to tell this function if they should be
      //  "untargetted", such as when they're destroyed, or stay targeted.
      result = target.interact(player);
      player.target = null;
    } else {
      // If we're not targeting a resource, assume we'd like to setup camp.
      result = setupCamp();
    }

    return result;
  }

  /// Add a camp object to the map.
  /// TODO: Setting up camp should take time.
  ActionResult setupCamp() {
    late Vec targetPos;
    // Assume place camp to south if player is not facing a direction.
    if (_player.direction == Direction.none) {
      targetPos = _player.pos + Direction.s.adjustmentVec;
    } else {
      targetPos = _player.pos + _player.direction.adjustmentVec;
    }

    // Camp is blocked, don't place.
    if (game.stage.resourceAt(targetPos) != null) {
      return ActionResult.failure;
    }

    var prevCamp = _player.camp;
    if (prevCamp != null) {
      game.stage.removeResource(prevCamp);
    }

    var camp = ResourceType.camp.newResource(_player.game, targetPos);
    _player.camp = camp;
    game.stage.addResource(camp);
    return ActionResult.success;
  }
}
