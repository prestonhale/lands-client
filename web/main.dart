import 'dart:html' as html;
import 'dart:js';
import 'dart:math' as math;

import 'package:lands/src/content/content.dart';
import 'package:lands/src/ui/input.dart';
import 'package:lands/src/ui/game_screen.dart';

import 'package:malison/malison.dart';
import 'package:malison/malison_web.dart';

const terminalMinWidth = 10;
const terminalMinHeight = 10;
final _fonts = <TerminalFont>[];
late final UserInterface<Input> _ui;
late TerminalFont _font;

// final Set<Monster> _debugMonsters = {};

class TerminalFont {
  final String name;
  final html.CanvasElement canvas;
  RenderableTerminal terminal;
  final int charWidth;
  final int charHeight;

  TerminalFont(this.name, this.canvas, this.terminal,
      {required this.charWidth, required this.charHeight});
}

void main() {
  var content = createContent();

  _addFont("8x8", 8);
  _addFont("8x10", 8, 10);
  _addFont("9x12", 9, 12);
  _addFont("10x12", 10, 12);
  _addFont("16x16", 16);
  _addFont("16x20", 16, 20);

  // Load the user's font preference, if any.
  var fontName = html.window.localStorage["font"];
  _font = _fonts[1];
  for (var thisFont in _fonts) {
    if (thisFont.name == fontName) {
      _font = thisFont;
      break;
    }
  }

  var div = html.querySelector("#game")!;
  div.append(_font.canvas);

  /// Scale the terminal to fit the screen.
  html.window.onResize.listen((_) {
    _resizeTerminal();
  });

  _ui = UserInterface<Input>(_font.terminal);

  _ui.keyPress.bind(Input.n, KeyCode.w);
  _ui.keyPress.bind(Input.e, KeyCode.d);
  _ui.keyPress.bind(Input.s, KeyCode.s);
  _ui.keyPress.bind(Input.w, KeyCode.a);

  _ui.keyPress.bind(Input.interact, KeyCode.space);

  _ui.push(GameScreen.main(content));

  _ui.handlingInput = true;
  _ui.running = true;

  // if (Debug.enabled) {
  //   html.document.body!.onKeyDown.listen((_) {
  //     _refreshDebugBoxes();
  //   });
  // }
}

void _addFont(String name, int charWidth, [int? charHeight]) {
  charHeight ??= charWidth;

  var canvas = html.CanvasElement();
  canvas.onDoubleClick.listen((_) {
    _fullscreen();
  });

  var terminal = _makeTerminal(canvas, charWidth, charHeight);
  _fonts.add(TerminalFont(name, canvas, terminal,
      charWidth: charWidth, charHeight: charHeight));

  // if (Debug.enabled) {
  //   // Clicking a monster toggles its debug pane.
  //   canvas.onClick.listen((event) {
  //     var gameScreen = Debug.gameScreen as GameScreen?;
  //     if (gameScreen == null) return;

  //     var pixel = Vec(event.offset.x.toInt(), event.offset.y.toInt());
  //     var pos = terminal.pixelToChar(pixel);

  //     var absolute = pos + gameScreen.cameraBounds.topLeft;
  //     if (!gameScreen.cameraBounds.contains(absolute)) return;

  //     var actor = gameScreen.game.stage.actorAt(absolute);
  //     if (actor is Monster) {
  //       if (_debugMonsters.contains(actor)) {
  //         _debugMonsters.remove(actor);
  //       } else {
  //         _debugMonsters.add(actor);
  //       }

  //       _refreshDebugBoxes();
  //     }
  //   });
  // }

  // Make a button for it.
  var button = html.ButtonElement();
  button.innerHtml = name;
  button.onClick.listen((_) {
    for (var i = 0; i < _fonts.length; i++) {
      if (_fonts[i].name == name) {
        _font = _fonts[i];
        html.querySelector("#game")!.append(_font.canvas);
      } else {
        _fonts[i].canvas.remove();
      }
    }

    _resizeTerminal();

    // if (Debug.enabled) _refreshDebugBoxes();

    // Remember the preference.
    html.window.localStorage['font'] = name;
  });

  html.querySelector('.button-bar')!.children.add(button);
}

RetroTerminal _makeTerminal(
    html.CanvasElement canvas, int charWidth, int charHeight) {
  var width = (html.document.body!.clientWidth - 20) ~/ charWidth;
  var height = (html.document.body!.clientHeight - 30) ~/ charHeight;

  width = math.max(width, terminalMinWidth);
  height = math.max(height, terminalMinHeight);

  var scale = html.window.devicePixelRatio.toInt();
  var canvasWidth = charWidth * width;
  var canvasHeight = charHeight * height;
  canvas.width = canvasWidth * scale;
  canvas.height = canvasHeight * scale;
  canvas.style.width = "${canvasWidth}px";
  canvas.style.height = "${canvasHeight}px";

  // Make the terminal.
  var file = "font_$charWidth";
  if (charWidth != charHeight) file += "_$charHeight";
  return RetroTerminal(width, height, "$file.png",
      canvas: canvas,
      charWidth: charWidth,
      charHeight: charHeight,
      scale: html.window.devicePixelRatio.toInt());
}

/// Updates the character dimensions of the current terminal to fit the screen
/// size.
void _resizeTerminal() {
  var terminal = _makeTerminal(_font.canvas, _font.charWidth, _font.charHeight);

  _font.terminal = terminal;
  _ui.setTerminal(terminal);
}

/// See: https://stackoverflow.com/a/29715395/9457
void _fullscreen() {
  var div = html.querySelector("#game")!;
  var jsElement = JsObject.fromBrowserObject(div);

  var methods = [
    "requestFullscreen",
    "mozRequestFullScreen",
    "webkitRequestFullscreen",
    "msRequestFullscreen"
  ];
  for (var method in methods) {
    if (jsElement.hasProperty(method)) {
      jsElement.callMethod(method);
      return;
    }
  }
}

// Future<void> _refreshDebugBoxes() async {
//   // Hack: Give the engine a chance to update.
//   await html.window.animationFrame;

//   for (var debugBox in html.querySelectorAll(".debug")) {
//     html.document.body!.children.remove(debugBox);
//   }

  // var gameScreen = Debug.gameScreen as GameScreen?;
  // if (gameScreen == null) return;

  // _debugMonsters.removeWhere((monster) => !monster.isAlive);
  // for (var monster in _debugMonsters) {
  //   if (gameScreen.cameraBounds.contains(monster.pos)) {
  //     var screenPos = monster.pos - gameScreen.cameraBounds.topLeft;

  //     var info = Debug.monsterInfo(monster);
  //     if (info == null) continue;

  //     var debugBox = html.PreElement();
  //     debugBox.className = "debug";
  //     debugBox.style.display = "inline-block";

  //     var x = (screenPos.x + 1) * _font.charWidth +
  //         _font.canvas.offset.left.toInt() +
  //         4;
  //     var y = (screenPos.y) * _font.charHeight +
  //         _font.canvas.offset.top.toInt() +
  //         2;
  //     debugBox.style.left = x.toString();
  //     debugBox.style.top = y.toString();
  //     debugBox.text = info;

  //     html.document.body!.children.add(debugBox);
  //   }
  // }
// }
