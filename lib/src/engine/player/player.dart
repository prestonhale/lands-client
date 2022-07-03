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
    if (carrying != null) {
      return CharGlyph.fromCharCode(CharCode.at, Color.green);
    }
    switch (direction) {
      case Direction.none:
        {
          return CharGlyph.fromCharCode(CharCode.at);
        }
      case Direction.n:
        {
          return CharGlyph.fromCharCode(CharCode.upwardsArrow);
        }
      case Direction.e:
        {
          return CharGlyph.fromCharCode(CharCode.rightwardsArrow);
        }
      case Direction.s:
        {
          return CharGlyph.fromCharCode(CharCode.downwardsArrow);
        }
      case Direction.w:
        {
          return CharGlyph.fromCharCode(CharCode.leftwardsArrow);
        }
      default:
        {
          return CharGlyph.fromCharCode(CharCode.questionMark);
        }
    }
  }

  @override
  bool canMove(num gameTime) {
    // TODO: The additional ms delay for carrying should depend on WHAT is 
    //  being carried.
    if (carrying != null) return (gameTime - lastMoved) >= moveMs + 400;
    return (gameTime - lastMoved) >= moveMs;
  }

  @override
  void setNextAction(Action action) {
    _behavior = ActionBehavior(action);
  }

  @override
  Action onGetAction() => _behavior!.getAction(this);

  void waitForInput() {
    _behavior = null;
  }
}
