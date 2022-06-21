import 'dart:html' as html;

import 'package:lands/src/engine/core/game.dart';

final canvas = html.querySelector("canvas#editor") as html.CanvasElement;
Game? _game;

void main() {
  // Get file
  // Process with the game object
  // Render with the terminal
  // Detect clicks and update to XXX
  // Save file
  _game = Game();
  _tick(0);
  _tickB(0);
  build();
  print("Final ${_game!.ready}");
  return;
}

void build() {
  var path = '../island_layout.txt';
  html.HttpRequest.getString(path).then((String islandLayout) {
    // _tickC(0);
    print("layout received");
  });
}

void _tick(int i) {
  print("A $i");

  if (i < 10) checkGame(i).then(_tick);
}

void _tickB(int i) {
  print("B $i");

  if (i < 10) checkGame(i).then(_tickB);
}

void _tickC(int i) {
  print("C $i");
  print(_game!.ready);

  if (i < 100) checkGame(i).then(_tickC);
}

Future<int> checkGame(int i) async {
  await Future.delayed(Duration(seconds: 2));
  i++;
  return i;
}
