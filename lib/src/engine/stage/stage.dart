import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/engine/stage/tile.dart';
import 'package:lands/src/engine/core/game.dart';
import 'package:lands/src/engine/core/actor.dart';
import 'package:lands/src/engine/stage/resource.dart';

class Stage {
  final Game game;
  final Array2D<Tile> tiles;
  Rect get bounds => tiles.bounds;

  final _actors = <Actor>[];

  final _resources = <Resource>[];

  int _currentActorIndex = 0;

  Actor get currentActor => _actors[_currentActorIndex];

  int get width => tiles.width;

  int get height => tiles.height;

  Stage(this.game, int width, [int? height])
      : tiles = Array2D.generated(width, height ?? width, (_) => Tile()),
        _actorsByTile = Array2D(width, height ?? width, null),
        _resourcesByTile = Array2D(width, height ?? width, null);

  Tile operator [](Vec pos) => tiles[pos];

  /// A spatial partition to let us quickly locate an actor by tile.
  ///
  /// This is a performance bottleneck since pathfinding needs to ensure it
  /// doesn't step on other actors.
  ///
  /// TODO: Partion by world chunks or zones. This doesn't need to include the
  /// entire world state.
  final Array2D<Actor?> _actorsByTile;

  final Array2D<Resource?> _resourcesByTile;

  Actor? actorAt(Vec pos) => _actorsByTile[pos];

  Tile? tileAt(Vec pos) => tiles[pos];

  Resource? resourceAt(Vec pos) => _resourcesByTile[pos];

  Vec? getAdjacentEmptyPosition(Vec pos) {
    for (Direction dir in Direction.all) {
      var checkPos = pos + dir.adjustmentVec;
      if (resourceAt(checkPos) == null && actorAt(checkPos) == null) {
        return checkPos;
      }
    }
    return null;
  }

  void addActor(Actor actor) {
    assert(_actorsByTile[actor.pos] == null);

    _actors.add(actor);
    _actorsByTile[actor.pos] = actor;
  }

  void advanceActor() {
    _currentActorIndex = (_currentActorIndex + 1) % _actors.length;
  }

  void moveActor(Vec from, Vec to) {
    var actor = _actorsByTile[from];
    _actorsByTile[from] = null;
    _actorsByTile[to] = actor;
  }

  void addResource(Resource resource) {
    _resources.add(resource);
    _resourcesByTile[resource.pos] = resource;
  }

  void removeResource(Resource resource) {
    assert(_resourcesByTile[resource.pos] == resource);

    var index = _resources.indexOf(resource);
    _resources.removeAt(index);

    _resourcesByTile[resource.pos] = null;
  }
}
