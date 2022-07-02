import 'package:lands/src/engine/core/actor.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/action/action.dart';
import 'package:lands/src/engine/player/behavior.dart';
import 'package:lands/src/engine/stage/resource.dart';
import 'package:malison/malison.dart';

import 'package:piecemeal/piecemeal.dart';

class Player extends Actor {
  Player(Game game, Vec pos) : super(game, pos.x, pos.y);

  ActionBehavior? _behavior;

  Resource? camp;

  Resource? carrying;

  // If we have a behavior, we don't need input.
  @override
  bool get needsInput {
    return _behavior == null;
  }

  @override
  Object get appearance {
    switch (direction) {
      case Direction.none:
        {
          return CharCode.at;
        }
      case Direction.n:
        {
          return CharCode.upwardsArrow;
        }
      case Direction.e:
        {
          return CharCode.rightwardsArrow;
        }
      case Direction.s:
        {
          return CharCode.downwardsArrow;
        }
      case Direction.w:
        {
          return CharCode.leftwardsArrow;
        }
      default:
        {
          return CharCode.questionMark;
        }
    }
  }

  void setNextAction(Action action) {
    _behavior = ActionBehavior(action);
  }

  @override
  Action onGetAction() => _behavior!.getAction(this);

  void waitForInput() {
    _behavior = null;
  }
}
