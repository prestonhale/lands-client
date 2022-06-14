import 'package:lands/src/ui/input.dart';
import 'package:lands/src/engine/action/action.dart';
import 'package:lands/src/engine/action/walk.dart';

class GameScreen extends Screen<Input> {
  GameScreen(this.game);

  bool handleInput(Input input) {
    Action? action;
    switch (input) {
      case Input.n:
        action = WalkAction(Direction.n);
        break;
      case Input.e:
        action = WalkAction(Direction.e);
        break;
      case Input.s:
        action = WalkAction(Direction.s);
        break;
      case Input.w:
        action = WalkAction(Direction.w);
        break;
    }
  }

}