import 'dart:math' as math;

import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';

import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/core/math.dart';
import 'package:lands/src/ui/game_screen.dart';
import 'package:lands/src/engine/stage/tile.dart';
import 'package:lands/src/ui/panel/panel.dart';

class GamePanel extends Panel {
  int _frame = 0;

  /// The portion of the [Stage] currently in view on screen.
  Rect get cameraBounds => _cameraBounds;

  final GameScreen _gameScreen;

  bool _hasAnimatedTile = false;

  late Rect _cameraBounds;

  /// The amount of offset the rendered stage from the top left corner of the
  /// screen.
  ///
  /// This will be zero unless the stage is smaller than the view.
  late Vec _renderOffset;

  GamePanel(this._gameScreen);

  bool update(Iterable<Event> event) {
    _frame++;

    // return _hasAnimatedTile || hadEffects
    return true;
  }

  @override
  void renderPanel(Terminal terminal) {
    var game = _gameScreen.game;

    /// TODO: Should there be a max size to make gameplay fair?
    _positionCamera(terminal.size);

    for (var pos in _cameraBounds) {
      Glyph? glyph;
      var fore = Color.black;
      var back = Color.black;

      var tile = game.stage[pos];

      glyph = _tileGlyph(pos, tile);
      var tileBackground = glyph.back;

      var actor = game.stage.actorAt(pos);
      var resource = game.stage.resourceAt(pos);
      if (actor != null) {
        glyph = actor.appearance as Glyph;
      } else if (resource != null) {
        glyph = resource.appearance;
      }

      // All actors and resources should show the tile's background color
      // through their glyph.
      glyph = glyph.replaceBackground(tileBackground);

      // TODO: No need to render empty tiles
      if (glyph != null) {
        _drawStageGlyph(terminal, pos.x, pos.y, glyph);
      }
    }
  }

  /// Gets the [Glyph] to render for [tile]
  Glyph _tileGlyph(Vec pos, Tile tile) {
    var appearance = tile.type.appearance;

    // If the appearance is a single glyph, it's a static tile.
    if (appearance is Glyph) return appearance;

    // Otherwise its an animated tile with multiple frames, like water.
    var glyphs = appearance as List<Glyph>;

    // Ping pong back and forth
    var period = glyphs.length * 2 - 2;

    // Calculate a "random" but consistent phase for each position
    var phase = hashPoint(pos.x, pos.y); // Static for each tile
    var animationFrame = (_frame ~/ 8 + phase) % period;
    if (animationFrame >= glyphs.length) {
      animationFrame = glyphs.length - (animationFrame - glyphs.length) - 1;
    }

    _hasAnimatedTile = true;
    return glyphs[animationFrame];
  }

  void drawStageGlyph(Terminal terminal, int x, int y, Glyph glyph) {
    _drawStageGlyph(terminal, x + bounds.x, y + bounds.y, glyph);
  }

  void _drawStageGlyph(Terminal terminal, int x, int y, Glyph glyph) {
    terminal.drawGlyph(x - _cameraBounds.x + _renderOffset.x,
        y - _cameraBounds.y + _renderOffset.y, glyph);
  }

  void _positionCamera(Vec terminalSize) {
    var game = _gameScreen.game;

    // Handle the stage being smaller than the view.
    var rangeWidth = math.max(0, game.stage.width - terminalSize.x);
    var rangeHeight = math.max(0, game.stage.height - terminalSize.y);

    var cameraRange = Rect(0, 0, rangeWidth, rangeHeight);

    var camera = game.player.pos - terminalSize ~/ 2;
    camera = cameraRange.clamp(camera);
    _cameraBounds = Rect(
        camera.x,
        camera.y,
        math.min(terminalSize.x, game.stage.width),
        math.min(terminalSize.y, game.stage.height));

    _renderOffset = Vec(math.max(0, terminalSize.x - game.stage.width) ~/ 2,
        math.max(0, terminalSize.y - game.stage.height) ~/ 2);
  }
}
