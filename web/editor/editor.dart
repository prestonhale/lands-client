import 'dart:async';
import 'dart:html' as html;

import 'package:lands/src/engine/stage/tile.dart';
import 'package:lands/src/ui/draw.dart';
import 'package:malison/malison.dart';
import 'package:malison/malison_web.dart';
import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/engine.dart';

final canvas = html.querySelector("canvas#editor") as html.CanvasElement;
final document = html.document;
late RenderableTerminal terminal;

int selectedTileIndex = 0;
int selectedResourceIndex = -1;
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
    var tile = TileTypes.desert[selectedTileIndex];

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
      var pos = terminal.pixelToChar(pixel);

      stage[pos].type = TileTypes.desert[selectedTileIndex];

      render();
    }
  });

  document.onKeyDown.listen((event) {
    switch (event.keyCode) {
      case KeyCode.right:
        adjustSelection(1);
        break;
      case KeyCode.left:
        adjustSelection(-1);
        break;
      case KeyCode.down:
        switchTileOrResourceSelection();
        break;
      case KeyCode.up:
        switchTileOrResourceSelection();
        break;
    }
    event.preventDefault();
    render();
  });
}

void adjustSelection(int adjustment) {
  var tileLength = TileTypes.desert.length;
  var resourceLength = ResourceType.desert.length;
  if (selectedTileIndex != -1) {
    selectedTileIndex =
        (selectedTileIndex + adjustment + tileLength) % tileLength;
  } else {
    selectedResourceIndex =
        (selectedResourceIndex + adjustment + resourceLength) % resourceLength;
  }
}

void switchTileOrResourceSelection() {
  var tileLength = TileTypes.desert.length;
  var resourceLength = ResourceType.desert.length;
  if (selectedTileIndex != -1) {
    selectedResourceIndex = selectedTileIndex % resourceLength;
    selectedTileIndex = -1;
  } else {
    selectedTileIndex = selectedResourceIndex % tileLength;
    selectedResourceIndex = -1;
  }
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

  // Panel holding selections.
  Draw.doubleBox(terminal, 0, 0, terminal.width, 10);

  // First row, tiles.
  terminal.writeAt(1, 2, "Tiles:");
  for (var i = 0; i < TileTypes.desert.length; i++) {
    var frameTopLeft = Vec(8 + (3 * i), 1);
    Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3);
    if (i == selectedTileIndex) {
      Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3, Color.white);
    }
    var appearance = TileTypes.desert[i].appearance;
    terminal.drawGlyph(
        frameTopLeft.x + 1, frameTopLeft.y + 1, appearance as VecGlyph);
  }

  // Second row, resources.
  terminal.writeAt(1, 6, "Resrcs:");
  for (var i = 0; i < ResourceType.desert.length; i++) {
    var frameTopLeft = Vec(8 + (3 * i), 5);
    Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3);
    if (selectedResourceIndex != null && i == selectedResourceIndex) {
      Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3, Color.white);
    }
    var appearance = TileTypes.desert[i].appearance;
    terminal.drawGlyph(
        frameTopLeft.x + 1, frameTopLeft.y + 1, appearance as VecGlyph);
  }

  terminal.render();
}
