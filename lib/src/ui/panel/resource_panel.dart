import 'package:malison/malison.dart';

import 'package:lands/src/ui/game_screen.dart';
import 'package:lands/src/ui/panel/panel.dart';

class ResourcePanel extends Panel {
  final GameScreen _gameScreen;

  ResourcePanel(this._gameScreen);

  @override
  bool get pinToTop => true;

  @override
  void renderPanel(Terminal terminal) {
    var target = _gameScreen.game.player.target;
    if (target != null) {
      target.renderTargetPanel(terminal);
    }
  }
}
