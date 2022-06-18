import 'package:lands/src/engine/core/actor.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/action/action.dart';
import 'package:lands/src/engine/player/behavior.dart';

import 'package:piecemeal/piecemeal.dart';

class Player extends Actor {
  Player(Game game, Vec pos) : super(game, pos.x, pos.y);

  ActionBehavior? _behavior;

  // If we have a behavior, we don't need input.
  @override
  bool get needsInput {
    return _behavior == null;
  }

  @override
  Object get appearance => "player";

  void setNextAction(Action action) {
    _behavior = ActionBehavior(action);
  }

  @override
  Action onGetAction() => _behavior!.getAction(this);

  void waitForInput() {
    _behavior = null;
  }
}
