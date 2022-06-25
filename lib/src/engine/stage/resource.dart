import 'dart:html';
import 'dart:math';

import 'package:lands/src/engine.dart';
import 'package:lands/src/engine/action/action.dart';
import 'package:malison/malison.dart';
import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/hues.dart';

import 'package:lands/src/ui/draw.dart';

// Represents the result of an [Actor] attempting to interact with this [Resource].
abstract class Interaction {
  ActionResult interact(Resource resource, Actor actor);
}

class CactusInteraction implements Interaction {
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Cactus");

    var player = actor as Player;

    var stage = resource.game.stage;
    stage.removeResource(resource);

    actor.carrying = resource;

    return ActionResult.success;
  }
}

class CraftingInteraction implements Interaction {
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Crafting");
    return ActionResult.success;
  }
}

class CampInteraction implements Interaction {
  int cacti = 0;

  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Camp");

    var player = actor as Player;

    if (player.carrying != null) {
      player.carrying = null;
      resource.cacti++;
      print("Deposited");
    }
    return ActionResult.success;
  }
}

class NoOpInteraction implements Interaction {
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] NoOP");
    return ActionResult.success;
  }
}

// Represents how the "Resource Panel" ui element should show present resource.
abstract class TargetPanelRenderer {
  void render(Resource resource, Terminal terminal);
}

class NotargetPanel implements TargetPanelRenderer {
  void render(Resource resource, Terminal terminal) {}
}

class HarvestTargetPanel implements TargetPanelRenderer {
  void render(Resource resource, Terminal terminal) {
    Draw.frame(terminal, 0, 0, terminal.width, terminal.height);
    Draw.box(terminal, 2, 1, 3, 3);

    terminal.drawGlyph(3, 2, resource.appearance);
    terminal.writeAt(5, 2, resource.name);

    terminal.writeAt(1, 5, "Quality");
    terminal.writeAt(9, 5, resource.quality.toString());
    Draw.meter(terminal, 12, 5, terminal.width - 13, resource.quality, 100, red,
        maroon);
  }
}

class CampTargetPanel implements TargetPanelRenderer {
  void render(Resource resource, Terminal terminal) {
    Draw.frame(terminal, 0, 0, terminal.width, terminal.height);
    Draw.box(terminal, 2, 1, 3, 3);

    // Show the target's appearance in a small box
    terminal.drawGlyph(3, 2, resource.appearance);
    terminal.writeAt(5, 2, resource.name);

    // Stats
    terminal.writeAt(1, 5, "Cactus");
    terminal.writeAt(9, 5, resource.cacti.toString());
    Draw.meter(terminal, 12, 5, terminal.width - 13, resource.cacti, 100, red,
        maroon);
  }
}

class Resource {
  final Game game;

  final ResourceType _type;

  ResourceType get type => _type;

  final Vec _pos;

  late final int quality;

  int cacti = 0;

  Vec get pos => _pos;

  TileType get tile => _type.defaultTile;

  Glyph get appearance => _type.appearance;

  String get name => _type.name;

  ActionResult interact(Actor actor) => _type.interact(this, actor);

  void renderTargetPanel(Terminal terminal) =>
      _type.renderTargetPanel(this, terminal);

  // A private constructor. The only way to create a resource is via [ResourceType.newResource()].
  Resource._(this.game, this._type, this._pos) {
    quality = Random().nextInt(100);
  }
}

/// A single kind of [Resource] in the game.
class ResourceType {
  static final reed = ResourceType(
      'reed',
      VecGlyph.fromVec(Vec(27, 7), sherwood, gold),
      TileTypes.sand1,
      NoOpInteraction(),
      HarvestTargetPanel());

  static final cactus = ResourceType(
      'cactus',
      VecGlyph.fromVec(Vec(29, 4), peaGreen, gold),
      TileTypes.sand1,
      CactusInteraction(),
      HarvestTargetPanel());

  static final camp = ResourceType(
      'camp',
      VecGlyph.fromVec(Vec(3, 7), peaGreen, gold),
      TileTypes.flagstoneWall,
      CampInteraction(),
      CampTargetPanel());

  static final craftingSpot = ResourceType(
      'crafting spot',
      VecGlyph.fromVec(Vec(3, 7), peaGreen, gold),
      TileTypes.flagstoneWall,
      CraftingInteraction(),
      NotargetPanel());

  static final desert = [reed, cactus];

  final Interaction _interaction;

  final TargetPanelRenderer _panelRenderer;

  ResourceType(this.name, this.appearance, this.defaultTile, this._interaction,
      this._panelRenderer);

  Resource newResource(Game game, Vec pos) {
    return Resource._(game, this, pos);
  }

  ActionResult interact(Resource resource, Actor actor) {
    return _interaction.interact(resource, actor);
  }

  void renderTargetPanel(Resource resource, Terminal terminal) =>
      _panelRenderer.render(resource, terminal);

  final String name;
  final Glyph appearance;
  final TileType defaultTile;

  @override
  String toString() => "${defaultTile}";
}

// Harvesting does nothing.
void harvestNoOp(Resource resource) {}

// Harvest a cactus type.
void harvestCactus(Resource resource) {
  var stage = resource.game.stage;
  stage.removeResource(resource);
  stage.addResource(ResourceType.reed.newResource(resource.game, resource.pos));
}
