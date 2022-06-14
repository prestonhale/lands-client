import 'package:lands/src/engine/core/actor.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/action/action.dart';

import 'package:piecemeal/piecemeal.dart';

class Player extends Actor {

  Player(Game game, Vec pos) : super(game, pos.x, pos.y){}

  void setNextAction (Action action){

  }
}