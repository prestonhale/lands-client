import 'package:piecemeal/piecemeal.dart';

abstract class Actor{
  final Game game;

  Vec _pos;

  Vec get pos => _pos;

  set pos(Vec value) {
    if (value != _pos) {
      changePosition(_pos, value);
      _pos = value;
    }
  }

  int get x => pos.x;

  set x (int value) {
    pos = Vec(x, value);
  }

  int get y => pos.y;

  set y (int value) {
    pos = Vec(value, y);
  }

  Actor(this.game, int x, int y) : _pos = Vec(x, y);

  /// Called when the actor's position is about to change from [from] to [to].
  void changePosition(Vec from, Vec to) {
    game.stage.moveActor(from, to);
  }
}