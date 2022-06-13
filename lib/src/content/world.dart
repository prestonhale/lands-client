import 'tiles.dart';
import 'package:piecemeal/piecemeal.dart';

class TutorialIsland {
  final Array2D<Tile> tiles;
  Rect get bounds => tiles.bounds;

  TutorialIsland(int width, [int? height])
    : tiles = Array2D.generated(width, height ?? width, (_) => Tile());
  

  Iterable<String> generateIsland() sync* {
    // Cover placespace with sand
    for (var pos in bounds){
      tiles[pos].type = TileTypes.sand;
    }
  }
}