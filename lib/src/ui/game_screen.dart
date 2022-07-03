import 'dart:web_gl';

import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';
import 'package:malison/malison_web.dart';

import 'package:lands/src/ui/panel/game_panel.dart';
import 'package:lands/src/ui/panel/resource_panel.dart';
import 'package:lands/src/ui/input.dart';
import 'package:lands/src/hues.dart';
import 'package:lands/src/engine/core/game.dart';

import 'package:lands/src/engine/action/action.dart';
import 'package:lands/src/engine/action/change_direction.dart';
import 'package:lands/src/engine/action/walk.dart';
import 'package:lands/src/engine/action/interact.dart';

const resourcePanelWidth = 24;

class GameScreen extends Screen<Input> {
  final Game game;

  late final GamePanel _gamePanel;
  late final ResourcePanel _resourcePanel;

  bool isNorthHeld = false;
  bool isEastHeld = false;
  bool isSouthHeld = false;
  bool isWestHeld = false;

  GameScreen(this.game) {
    _gamePanel = GamePanel(this);
    _resourcePanel = ResourcePanel(this);
  }

  factory GameScreen.main(Content content) {
    var game = Game();
    print("generate");
    for (var _ in game.generate());

    return GameScreen(game);
  }

  @override
  bool handleInput(Input input) {
    Action? action;
    switch (input) {
      case Input.interact:
        action = InteractAction(game.player);
        break;

      case Input.n:
        isNorthHeld = true;
        if (isEastHeld) {
          action = WalkAction(game.player, Direction.ne);
        } else if (isWestHeld) {
          action = WalkAction(game.player, Direction.nw);
        } else {
          action = WalkAction(game.player, Direction.n);
        }
        break;
      case Input.e:
        isEastHeld = true;
        if (isNorthHeld) {
          action = WalkAction(game.player, Direction.ne);
        } else if (isSouthHeld) {
          action = WalkAction(game.player, Direction.se);
        } else {
          action = WalkAction(game.player, Direction.e);
        }
        break;
      case Input.s:
        isSouthHeld = true;
        if (isEastHeld) {
          action = WalkAction(game.player, Direction.se);
        } else if (isWestHeld) {
          action = WalkAction(game.player, Direction.sw);
        } else {
          action = WalkAction(game.player, Direction.s);
        }
        break;
      case Input.w:
        isWestHeld = true;
        if (isNorthHeld) {
          action = WalkAction(game.player, Direction.nw);
        } else if (isSouthHeld) {
          action = WalkAction(game.player, Direction.sw);
        } else {
          action = WalkAction(game.player, Direction.w);
        }
        break;

      case Input.dirN:
        action = ChangeDirectionAction(game.player, Direction.n);
        break;
      case Input.dirE:
        action = ChangeDirectionAction(game.player, Direction.e);
        break;
      case Input.dirS:
        action = ChangeDirectionAction(game.player, Direction.s);
        break;
      case Input.dirW:
        action = ChangeDirectionAction(game.player, Direction.w);
        break;
    }

    if (action != null) game.player.setNextAction(action);

    return true;
  }

  @override
  bool keyUp(int keyCode, {required bool shift, required bool alt}) {
    switch (keyCode) {
      case KeyCode.w:
        isNorthHeld = false;
        return true;
      case KeyCode.d:
        isEastHeld = false;
        return true;
      case KeyCode.s:
        isSouthHeld = false;
        return true;
      case KeyCode.a:
        isWestHeld = false;
        return true;
    }
    return false;
  }

  Color get playerColor {
    return ash;
  }

  @override
  void update(num time) {
    var result = game.update(time);

    if (result.needsRefresh) dirty();
  }

  @override
  void resize(Vec terminalSize) {
    _gamePanel.setBounds(Rect(0, 0, terminalSize.x, terminalSize.y));
    // Resource panels are full height by default so that the panel's logic can
    // control the height. If we specify a height here, the actual height can 
    // never exceed that height.
    _resourcePanel.setBounds(Rect(terminalSize.x ~/ 2 - resourcePanelWidth ~/ 2,
        0, resourcePanelWidth, terminalSize.y));
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
