import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/content/tiles.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/core/actor.dart';

class Stage {
  final Game game;
  final Array2D<Tile> tiles;
  Rect get bounds => tiles.bounds;

  final _actors = <Actor>[];

  Stage(this.game, int width, [int? height])
    : tiles = Array2D.generated(width, height ?? width, (_) => Tile()),
      _actorsByTile = Array2D(width, height ?? width, null);
  

  Iterable<String> generateIsland() sync* {
    // Cover placespace with sand
    for (var pos in bounds){
      tiles[pos].type = TileTypes.sand;
    }
  }

  Tile operator [](Vec pos) => tiles[pos];

  /// A spatial partition to let us quickly locate an actor by tile.
  ///
  /// This is a performance bottleneck since pathfinding needs to ensure it
  /// doesn't step on other actors.
  /// 
  /// TODO: Partion by world chunks or zones. This doesn't need to include the 
  /// entire world state.
  final Array2D<Actor?> _actorsByTile;

  void addActor(Actor actor) {
    assert(_actorsByTile[actor.pos] == null);

    _actors.add(actor);
    _actorsByTile[actor.pos] = actor;
  }

  void moveActor(Vec from, Vec to) {
    var actor = _actorsByTile[from];
    _actorsByTile[from] = null;
    _actorsByTile[to] = actor;
  }
}