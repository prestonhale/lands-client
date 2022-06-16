import 'package:lands/src/engine/core/actor.dart';
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

  GameResult update() {
    /// TODO: Always render
    return GameResult(true);
  }
}

/// Each call to [Game.update()] will return a [GameResult] object that tells
/// the UI what happened during that update and what it needs to do.
class GameResult {
  /// The "interesting" events that occurred in this update.
  final events = <Event>[];

  /// Whether or not any game state has changed. If this is `false`, then no
  /// game processing has occurred (i.e. the game is stuck waiting for user
  /// input).
  final bool madeProgress;

  /// Returns `true` if the game state has progressed to the point that a change
  /// should be shown to the user.
  bool get needsRefresh => madeProgress || events.isNotEmpty;

  GameResult(this.madeProgress);
}

/// Describes a single "interesting" thing that occurred during a call to
/// [Game.update()]. In general, events correspond to things that a UI is likely
/// to want to display visually in some form.
class Event {
  final EventType type;
  // TODO: Having these all be nullable leads to a lot of "!" in effects.
  // Consider a better way to model this.
  final Actor? actor;
  // final Element element;
  final Object? other;
  // final Vec? pos;
  // final Direction? dir;

  Event(this.type, this.actor, this.other);
}

class EventType {
  static const thing = EventType("thing");

  final String _name;

  const EventType(this._name);

  @override
  String toString() => _name;
}

abstract class Content {}
