import 'package:malison/malison.dart';

import 'package:lands/src/ui/game_screen.dart';
import 'package:lands/src/ui/panel/panel.dart';
import 'package:lands/src/hues.dart';
import 'package:lands/src/ui/draw.dart';

class ResourcePanel extends Panel {
  final GameScreen _gameScreen;

  ResourcePanel(this._gameScreen);

  @override
  bool get pinToTop => true;

  @override
  void renderPanel(Terminal terminal) {
    if (_gameScreen.game.player.target != null) {
      // Player target is not null. If it was this panel would be hidden. See
      // GameScreen.render.
      var resource = _gameScreen.game.player.target!;
      // TODO: Get from playerTarget.
      Draw.frame(terminal, 0, 0, terminal.width, terminal.height);
      Draw.box(terminal, 2, 1, 3, 3);

      // TODO: The player is the only thing NOT returning a glyph as
      //  appearance right now. If the player targets themselves(???) this
      //  will be a runtime error. Animated glyphs might also be an issue.
      terminal.drawGlyph(3, 2, resource.tile.appearance as Glyph);
      terminal.writeAt(5, 2, resource.tile.name);

      terminal.writeAt(1, 5, "Quality");
      terminal.writeAt(9, 5, resource.quality.toString());
      Draw.meter(terminal, 12, 5, terminal.width - 13, resource.quality, 100, red, maroon);
    }
  }
}
