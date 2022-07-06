import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/engine/stage/resource.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/action/action.dart';


// An active entity. Takes actions independently.
abstract class Actor {
  final Game game;
  Object get appearance;

  static final int speed = 10; // Times this actor can move every 2 seconds.
  int get moveMs => 2000 ~/ speed;

  num lastMoved = 0;

  bool get needsInput => false;

  Vec _pos;

  Vec get pos => _pos;

  set pos(Vec value) {
    if (value != _pos) {
      changePosition(_pos, value);
      _pos = value;
    }
  }

  // Should non-player actors have targets?
  Resource? _target;

  Resource? get target => _target;

  set target(Resource? resource) => _target = resource;

  // Should non-player actors have directions;
  Direction _direction;

  Direction get direction => _direction;

  bool canMove(num gameTime) {
    return (gameTime - lastMoved) >= moveMs;
  }

  // Noop for NPCs but used on players
  void setNextAction(Action action) {}

  set direction(Direction value) {
    if (value != _direction) {
      _direction = value;
    }
  }

  int get x => pos.x;

  set x(int value) {
    pos = Vec(x, value);
  }

  int get y => pos.y;

  set y(int value) {
    pos = Vec(value, y);
  }

  Actor(this.game, int x, int y)
      : _pos = Vec(x, y),
        _direction = Direction.none;

  Action getAction() {
    var action = onGetAction();
    return action;
  }

  Action onGetAction();

  /// Called when the actor's position is about to change from [from] to [to].
  void changePosition(Vec from, Vec to) {
    game.stage.moveActor(from, to);
  }

  /// Can the actor occupy the tile at [pos]. Does no checking of game state at
  /// [pos] (actors, resources, etc.).
  bool canOccupy(Vec pos) {
    if (pos.x < 0) return false;
    if (pos.x >= game.stage.width) return false;
    if (pos.y < 0) return false;
    if (pos.y >= game.stage.height) return false;

    var resource = game.stage.resourceAt(pos);
    if (resource != null) {
      return !resource.solid;
    }
    var tile = game.stage[pos];
    return tile.type.canEnter;
  }
}
