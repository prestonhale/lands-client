import 'dart:collection';

import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/engine/core/actor.dart';
import 'package:lands/src/engine/stage/tile.dart';
import 'package:lands/src/engine/stage/stage.dart';
import 'package:lands/src/engine/player/player.dart';
import 'package:lands/src/engine/action/action.dart';

const _islandLayout = [
      r"       SSSSSS       ",
      r"      SSSSSSS       ",
      r"     SSYSYSSSSS     ",
      r"    SSScYScSSSSSS   ",
      r"   SSSSSSSSSSSSSSS  ",
      r"  SSSSSYScSSSSSSS   ",
      r"   SSSScSSSSSSS     ",
      r"   SSSScSSSSSSS     ",
      r"    SSSSrrSYSSS     ",
      r"    SSrwwrSSYSS     ",
      r"     SSrrSSYSYSSS   ",
      r"      SSSSSYSSSSS   ",
      r"       SSSSSSSSS    ",
];

final Map<String, TileType> _tileTypeMapping = {
  " ": TileTypes.sea,
  "S": TileTypes.sand1,
  "c": TileTypes.sand2,
  "Y": TileTypes.cacti,
  "r": TileTypes.reed,
  "w": TileTypes.water,
};

class Game {
  late Stage _stage;
  late Player player;

  Stage get stage => _stage;

  final _actions = Queue<Action>();

  Game({int? width, int? height}) {
    _stage = Stage(this, width ?? _islandLayout[0].length, height ?? _islandLayout.length);
  }

  Iterable<String> generate() sync* {
    yield* buildTutorialIsland();

    player = Player(this, stage.bounds.center);
    _stage.addActor(player);
  }

  Iterable<String> buildTutorialIsland() sync* {
    for (var y = 0; y < _islandLayout.length; y++) {
      for (var x = 0; x < _islandLayout[y].length; x++) {
        var pos = Vec(x, y);
        var tileType = _tileTypeMapping[_islandLayout[y][x]];
        tileType ??= TileTypes.error;
        stage[pos].type = tileType;
      }
    }
  }

  GameResult update() {
    var stateWasUpdated = false;

    while (true) {
      // If any actions are already pending, process them until empty.
      while (_actions.isNotEmpty) {
        var action = _actions.first;

        var result = action.perform();

        stateWasUpdated = true;

        if (result.done) {
          _actions.removeFirst();

          if (result.succeeded) {
            stage.advanceActor();
          }

          // Always refresh when the player acts
          if (action.actor == player) return GameResult(stateWasUpdated);
        }
      }

      // Cycle through all stage actors and add their actions to the pending
      // actions list
      while (_actions.isEmpty) {
        var actor = stage.currentActor;

        // Right now, needsInput is only ever true for the player. So this is
        // is true whenever we have no player input.
        if (actor.needsInput) {
          return GameResult(stateWasUpdated);
        } else {
          // Exit out of this loop as an action is now queued.
          _actions.add(actor.getAction());
        }
      }
    }
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
