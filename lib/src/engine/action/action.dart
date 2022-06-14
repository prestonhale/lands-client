import 'package:lands/src/engine/core/actor.dart';

abstract class Action {
  final Actor _actor;

  Action(this._actor);

  // Why not just make this field public?
  Actor get actor => _actor;

  bool onPerform();
}