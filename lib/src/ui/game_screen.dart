import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';
import 'package:malison/malison_web.dart';

import 'package:lands/src/ui/input.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/action/action.dart';
import 'package:lands/src/engine/action/walk.dart';

class GameScreen extends Screen<Input> {
  final Game game;

  late final GamePanel _gamePanel;

  GameScreen(this.game) {
    _gamePanel = GamePanel(this);
  };

  factory GameScreen.main(Content content) {
    var game = Game();
    for (var _ in game.generate()) {}
    ;

    return GameScreen(game);
  }

  @override
  bool handleInput(Input input) {
    Action? action;
    switch (input) {
      case Input.n:
        action = WalkAction(game.player, Direction.n);
        break;
      case Input.e:
        action = WalkAction(game.player, Direction.e);
        break;
      case Input.s:
        action = WalkAction(game.player, Direction.s);
        break;
      case Input.w:
        action = WalkAction(game.player, Direction.w);
        break;
    }

    if (action != null) game.player.setNextAction(action);

    return true;
  }

  void update() {
    var result = game.update();

    if (result.needsRefresh) dirty();
  }

  void render(Terminal terminal) {
    terminal.clear();
    _gamePanel.render(terminal);
  }
}
