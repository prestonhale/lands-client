import 'dart:async';
import 'dart:html' as html;
import 'dart:convert' show utf8;

import 'package:lands/src/engine/stage/serializer.dart';
import 'package:lands/src/ui/draw.dart';
import 'package:malison/malison.dart';
import 'package:malison/malison_web.dart';
import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/engine.dart';

final canvas = html.querySelector("canvas#editor") as html.CanvasElement;
final document = html.document;
late RenderableTerminal terminal;

var charSize = 16;
var selectionPanelHeight = 8;
var selectionPanelOffset = charSize * selectionPanelHeight;

int selectedTileIndex = 0;
int selectedResourceIndex = -1;
bool _placing = false;

Game _game = Game();

void main() async {
  _game = Game();
  for (var _ in _game.generate()) {}
  // Wait for the game to be ready.
  await checkGame();

  var stage = _game.stage;

  // TODO: Make this work with browser scale not just terminal scale.
  var scale = 1;
  terminal = RetroTerminal(
      stage.width, stage.height + selectionPanelOffset, "../font_16.png",
      canvas: canvas, charWidth: charSize, charHeight: charSize, scale: scale);
  canvas.width = (stage.width * charSize * scale).round();
  canvas.height =
      (stage.height * charSize * scale + selectionPanelOffset).round();
  render();

  // contextMenu is 'javascript' for right-click.
  canvas.onContextMenu.listen((event) {
    var tile = TileTypes.sand1;

    var stage = _game.stage;
    var pixel = Vec(
        event.offset.x.toInt(), event.offset.y.toInt() - selectionPanelOffset);
    var pos = terminal.pixelToChar(pixel);

    stage[pos].type = tile;
    event.preventDefault();

    render();
  });

  canvas.onClick.listen((event) {
    var pixel = Vec(
        event.offset.x.toInt(), event.offset.y.toInt() - selectionPanelOffset);
    var pos = terminal.pixelToChar(pixel);

    placeSelection(pos);

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
      var pixel = Vec(event.offset.x.toInt(),
          event.offset.y.toInt() - selectionPanelOffset);
      var pos = terminal.pixelToChar(pixel);

      placeSelection(pos);

      render();
    }
  });

  document.onKeyDown.listen((event) {
    switch (event.keyCode) {
      case KeyCode.right:
        adjustSelection(1);
        event.preventDefault();
        break;
      case KeyCode.left:
        adjustSelection(-1);
        event.preventDefault();
        break;
      case KeyCode.down:
        switchTileOrResourceSelection();
        event.preventDefault();
        break;
      case KeyCode.up:
        switchTileOrResourceSelection();
        event.preventDefault();
        break;
      case KeyCode.s:
        save();
        event.preventDefault();
        break;
    }
    render();
  });

  document.onScroll.listen((_) {
    render();
  });
}

void placeSelection(Vec pos) {
  var stage = _game.stage;

  // Placing a raw tile without resource.
  if (selectedTileIndex != -1) {
    stage[pos].type = TileTypes.desert[selectedTileIndex];
    var resource = stage.resourceAt(pos);
    if (resource != null) {
      stage.removeResource(resource);
    }

    // Placing a resource and using its default tile.
  } else {
    ResourceType resourceType = ResourceType.desert[selectedResourceIndex];
    var resource = resourceType.newResource(_game, pos);
    stage[pos].type = resource.tile;
    stage.addResource(resource);
  }
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

/// Immediately prompt to download the current stage layout as a txt file.
void save() {
  var stage = _game.stage;

  var stringMap = "";

  var prevRow = 0;
  for (Vec pos in stage.bounds) {
    if (pos.y != prevRow) {
      prevRow = pos.y;
      stringMap += "\n";
    }

    // "Dehydrate" the objects at this location on the map.
    late SerializerCell cell;
    Resource? resource = stage.resourceAt(pos);
    if (resource != null) {
      cell = SerializerCell.fromResource(resource.type);
    } else {
      cell = SerializerCell.fromTile(stage.tileAt(pos)!.type);
    }
    stringMap += cell.dehydrate();

    // Reached the next row so add newline.
  }

  html.AnchorElement()
    ..href =
        '${Uri.dataFromString(stringMap, mimeType: 'text/plain', encoding: utf8)}'
    ..download = 'island_layout.txt'
    ..style.display = 'none'
    ..click();
}

Future<void> checkGame() async {
  while (!_game.ready) {
    // Poll frequently
    await Future.delayed(Duration(milliseconds: 200), (() => null));
  }
}

// Todo: Synchronize this with the actual game render func
void render() {
  renderGameStage(terminal.rect(0, selectionPanelHeight, _game.stage.width, _game.stage.height));

  // TODO: The scroll on this is pretty janky. Consider breaking the map out
  //  into its own terminal rather than relying on browser based scroll events.
  var x = html.window.scrollX ~/ charSize;
  var y = html.window.scrollY ~/ charSize;
  var viewportWidth = document.documentElement!.clientWidth ~/ charSize;
  renderSelectionBox(terminal.rect(x, y, viewportWidth, selectionPanelHeight));

  terminal.render();
}

void renderGameStage(Terminal terminal) {
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
      var resource = stage.resourceAt(pos);
      if (actor != null) {
        glyph = actor.appearance as Glyph;
      } else if (resource != null) {
        glyph = resource.appearance;
      }

      terminal.drawGlyph(x, y, glyph);
    }
  }
}

void renderSelectionBox(Terminal terminal) {
  // Panel holding selections.
  Draw.doubleBox(terminal, 0, 0, terminal.width, terminal.height);
  terminal.writeAt(2, 0, "Game Objects");

  // Tiles.
  terminal.writeAt(1, 2, "Tiles:");
  for (var i = 0; i < TileTypes.desert.length; i++) {
    var frameTopLeft = Vec(8 + (3 * i), 1);
    Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3);

    if (i == selectedTileIndex) {
      Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3, Color.white);
    }

    var appearance = TileTypes.desert[i].appearance;

    VecGlyph glyph;
    if (appearance is List<Glyph>) {
      glyph = appearance.first as VecGlyph;
    } else {
      glyph = appearance as VecGlyph;
    }
    terminal.drawGlyph(frameTopLeft.x + 1, frameTopLeft.y + 1, glyph);
  }

  // Harvestables.
  terminal.writeAt(1, 5, "Resrcs:");
  for (var i = 0; i < ResourceType.desert.length; i++) {
    var frameTopLeft = Vec(8 + (3 * i), 4);
    Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3);

    if (i == selectedResourceIndex) {
      Draw.box(terminal, frameTopLeft.x, frameTopLeft.y, 3, 3, Color.white);
    }

    var appearance = ResourceType.desert[i].appearance;

    terminal.drawGlyph(
        frameTopLeft.x + 1, frameTopLeft.y + 1, appearance as VecGlyph);
  }
}
