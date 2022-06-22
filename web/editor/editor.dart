import 'dart:async';
import 'dart:html' as html;

import 'package:malison/malison.dart';
import 'package:malison/malison_web.dart';
import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/engine.dart';

final canvas = html.querySelector("canvas#editor") as html.CanvasElement;
late RenderableTerminal terminal;

TileType selectedTile = TileTypes.sand1;
bool _placing = false;

Game _game = Game();

void main() async {
  // Get file
  // Process with the game object
  // Render with the terminal
  // Detect clicks and update to XXX
  // Save file
  _game = Game();
  for (var _ in _game.generate()) {}
  // Wait for the game to be ready.
  await checkGame();

  var stage = _game.stage;

  // TODO: Make this work with browser scale not just terminal scale.
  var scale = 3;
  terminal = RetroTerminal(stage.width, stage.height, "../font_8.png",
      canvas: canvas, charWidth: 8, charHeight: 8, scale: scale);
  canvas.width = (stage.width * 8 * scale).round();
  canvas.height = (stage.height * 8 * scale).round();
  render();

  // contextMenu is 'javascript' for right-click.
  canvas.onContextMenu.listen((event) {
    var tile = TileTypes.sand1;

    var stage = _game.stage;
    var pixel = Vec(event.offset.x.toInt(), event.offset.y.toInt());
    var pos = terminal.pixelToChar(pixel);

    stage[pos].type = tile;
    event.preventDefault();

    render();
  });

  canvas.onClick.listen((event) {
    var tile = TileTypes.cacti;

    var stage = _game.stage;
    var pixel = Vec(event.offset.x.toInt(), event.offset.y.toInt());
    var pos = terminal.pixelToChar(pixel);

    stage[pos].type = tile;

    render();
  });

  canvas.onMouseDown.listen((event) {
    if (event.ctrlKey) {
      _placing = true;
    }

    render();
  });

  canvas.onMouseUp.listen((event) {
    _placing = false;
  });

  canvas.onMouseOut.listen((event) {
    _placing = false;
  });

  canvas.onMouseMove.listen((event) {
    // TODO: Can we poll at a lesser rate? We're placing a LOT of cactuses on
    //  same square atm. Does this matter?
    if (_placing) {
      var stage = _game.stage;
      var pixel = Vec(event.offset.x.toInt(), event.offset.y.toInt());
      print(pixel);
      var pos = terminal.pixelToChar(pixel);

      stage[pos].type = TileTypes.cacti;

      render();
    }
  });
}

Future<void> checkGame() async {
  while (!_game.ready) {
    // Poll frequently
    await Future.delayed(Duration(milliseconds: 200), (() => null));
  }
}

// Todo: Synchronize this with the actual game render func
void render() {
  var stage = _game.stage;

  for (var y = 0; y < stage.height; y++) {
    for (var x = 0; x < stage.width; x++) {
      var pos = Vec(x, y);
      var tile = stage[pos];

      Glyph glyph;
      if (tile.type.appearance is Glyph) {
        glyph = tile.type.appearance as Glyph;
      } else {
        var glyphs = tile.type.appearance as List<Glyph>;
        // Calculate a "random" but consistent phase for each position.
        var phase = hashPoint(x, y);
        glyph = glyphs[phase % glyphs.length];
      }

      var actor = stage.actorAt(pos);
      if (actor != null) {
        var appearance = actor.appearance;
        if (appearance is Glyph) {
          glyph = appearance as VecGlyph;
        } else {
          // player
        }
      }

      terminal.drawGlyph(x, y, glyph);
    }
  }

  terminal.render();
}
