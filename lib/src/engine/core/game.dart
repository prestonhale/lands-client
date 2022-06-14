
import 'package:lands/src/content/tiles.dart';
import 'package:lands/src/engine/stage/stage.dart';
import 'package:lands/src/engine/player/player.dart';

class Game {
  late Stage _stage;
  late Player player;

  Stage get stage => _stage;

  Game({int? width, int? height}) {
    _stage = Stage(this, width ?? 80, height ?? 60);
  }

  Iterable<String> generate() sync* {
    yield* buildTutorialIsland();

    player = Player(this, stage.bounds.center);
    _stage.addActor(player);
  }

  Iterable<String> buildTutorialIsland() sync* {
    for (var pos in stage.bounds) {
      stage[pos].type = TileTypes.sand;
    }
    for (var pos in stage.bounds.trace()) {
      stage[pos].type = TileTypes.sand;
    }

  }
}

abstract class Content {

}