import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/core/actor.dart';
import 'package:lands/src/engine/core/game.dart';

abstract class Action {
  late final Actor _actor;
  final Game _game;
  final Vec _pos;

  Game get game => _game;

  Action(this._actor)
      : _pos = _actor.pos,
        _game = _actor.game;

  // Why not just make this field public?
  Actor get actor => _actor;

  // Why do we wrap [onPerform] like this?
  ActionResult perform() {
    return onPerform();
  }

  ActionResult onPerform();
}

class ActionResult {
  static const success = ActionResult(succeeded: true, done: true);
  static const failure = ActionResult(succeeded: false, done: true);

  final bool succeeded;

  /// `true` if the [Action] does not need any further processing.
  final bool done;

  const ActionResult({required this.succeeded, required this.done});
}
