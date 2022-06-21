import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';
import 'package:malison/malison_web.dart';

import 'package:lands/src/ui/panel/game_panel.dart';
import 'package:lands/src/ui/panel/resource_panel.dart';
import 'package:lands/src/ui/input.dart';
import 'package:lands/src/hues.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/action/action.dart';
import 'package:lands/src/engine/action/walk.dart';

const resourcePanelWidth = 24;
const resourcePanelHeight = 8;

class GameScreen extends Screen<Input> {
  final Game game;

  late final GamePanel _gamePanel;
  late final ResourcePanel _resourcePanel;

  GameScreen(this.game) {
    _gamePanel = GamePanel(this);
    _resourcePanel = ResourcePanel(this);
  }

  factory GameScreen.main(Content content) {
    var game = Game();
    for (var _ in game.generate()) {}

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

  Color get playerColor {
    return ash;
  }

  @override
  void update() {
    var result = game.update();

    if (result.needsRefresh) dirty();
  }

  @override
  void resize(Vec terminalSize) {
    _gamePanel.setBounds(Rect(0, 0, terminalSize.x, terminalSize.y));
    _resourcePanel.setBounds(Rect(terminalSize.x ~/ 2 - resourcePanelWidth ~/ 2,
        0, resourcePanelWidth, resourcePanelHeight));
  }

  @override
  void render(Terminal terminal) {
    if (!game.ready) {
      return;
    } 

    if (game.player.target == null) {
      _resourcePanel.hide(terminal);
    } else {
      _resourcePanel.show();
    }

    // Order matters here. Later panels are rendered "on top of" earlier
    // panels.
    terminal.clear();
    _gamePanel.render(terminal);
    _resourcePanel.render(terminal);
  }
}
