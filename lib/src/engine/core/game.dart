import 'dart:collection';
import 'dart:convert';
import 'dart:html';

import 'package:piecemeal/piecemeal.dart';

import 'package:lands/src/engine/core/actor.dart';
import 'package:lands/src/engine/stage/stage.dart';
import 'package:lands/src/engine/stage/serializer.dart';
import 'package:lands/src/engine/player/player.dart';
import 'package:lands/src/engine/action/action.dart';

class Game {
  late Stage _stage;
  late Player player;

  num lastFrameTime = 0;

  bool ready = false;
  bool _prevReadyState = false;

  bool get justBecameReady => _prevReadyState != ready;

  Stage get stage => _stage;

  final _actions = Queue<Action>();

  Game();

  Iterable<String> generate() sync* {
    buildTutorialIsland();
  }

  // Async, stage will not be filled until this function returns
  void buildTutorialIsland() async {
    print("[Layout Generation] Begin");
    var path = '../island_layout.txt';
    var islandLayout = await HttpRequest.getString(path);

    LineSplitter ls = LineSplitter();
    List<String> lines = ls.convert(islandLayout);

    _stage = Stage(this, lines[0].length, lines.length);

    for (var y = 0; y < lines.length; y++) {
      for (var x = 0; x < lines[y].length; x++) {
        var pos = Vec(x, y);

        // "Hydrate" a single character on the layout file into all the objects
        // that make up that part of a stage.
        if (lines[y][x] == '/n') continue;
        var cell = SerializerCell.rehydrate(lines[y][x]);
        stage[pos].type = cell.tile;
        var resourceType = cell.resource;
        if (resourceType != null) {
          stage.addResource(resourceType.newResource(this, pos));
        }
      }

    }
    player = Player(this, Vec(60, 17));
    _stage.addActor(player);
    ready = true;
    print("[Layout Generation] Done");
  }

  GameResult update(num frameTime) {
    if (!ready) {
      return GameResult(false);
    }

    // Force a render on the frame the game becomes active.
    // Without this, the GameScreen will remain black until receiving input.
    if (justBecameReady) {
      _prevReadyState = true;
      return GameResult(true);
    }

    var stateWasUpdated = false;

    lastFrameTime = frameTime;

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
