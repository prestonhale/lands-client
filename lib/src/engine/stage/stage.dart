import 'package:lands/src/content/tiles.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:piecemeal/piecemeal.dart';

class Stage {
  final Game game;
  final Array2D<Tile> tiles;
  Rect get bounds => tiles.bounds;

  Stage(this.game, int width, [int? height])
    : tiles = Array2D.generated(width, height ?? width, (_) => Tile());
  

  Iterable<String> generateIsland() sync* {
    // Cover placespace with sand
    for (var pos in bounds){
      tiles[pos].type = TileTypes.sand;
    }
  }
}