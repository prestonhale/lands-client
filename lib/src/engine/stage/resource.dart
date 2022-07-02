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
  @override
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
  @override
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Crafting");
    return ActionResult.success;
  }
}

class PackInteraction implements Interaction {
  @override
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Pack");
    return ActionResult.success;
  }
}

class CampInteraction implements Interaction {
  int count = 0;
  int max = 3;

  @override
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Camp");

    var player = actor as Player;

    if (count == max) {
      var success = givePackToPlayer(resource, player);
      if (success) count = 0;
      return ActionResult.success;
    }

    if (player.carrying != null) {
      player.carrying = null;
      if (count == max) {
        return ActionResult.failure;
      } else {
        count++;
      }
    }
    return ActionResult.success;
  }

  /// Gives the [Pack] to the player if the player's carry slot is free.
  /// Otherwise drops it on the ground in an adjacent square.
  bool givePackToPlayer(Resource camp, Player player) {
    var stage = player.game.stage;

    if (player.carrying == null) {
      var resource =
          ResourceType.cactusPack.newResource(player.game, player.pos);
      player.carrying = resource;
    } else {
      var foundPos = stage.getAdjacentEmptyPosition(camp.pos);

      if (foundPos != null) {
        var resource =
            ResourceType.cactusPack.newResource(player.game, foundPos);
        stage.addResource(resource);
      } else {
        // There's no adjacent empty positions, do not empty camp and do not 
        // produce a pack.
        return false;
      }
    }

    return true;
  }
}

class NoOpInteraction implements Interaction {
  @override
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] NoOP");
    return ActionResult.success;
  }
}

// Represents how the "Resource Panel" ui element should show present resource.
abstract class TargetPanelRenderer {
  void render(Resource resource, Terminal terminal);
}

class NoTargetPanel implements TargetPanelRenderer {
  void render(Resource resource, Terminal terminal) {}
}

class HarvestTargetPanel implements TargetPanelRenderer {
  @override
  void render(Resource resource, Terminal terminal) {
    // Framing Box
    Draw.frame(terminal, 0, 0, terminal.width, terminal.height);
    Draw.box(terminal, 2, 1, 3, 3);

    // Resource Image and Name
    terminal.drawGlyph(3, 2, resource.appearance);
    terminal.writeAt(5, 2, resource.name);

    // Quality Bar
    terminal.writeAt(1, 5, "Quality");
    terminal.writeAt(9, 5, resource.quality.toString());
    Draw.meter(terminal, 12, 5, terminal.width - 13, resource.quality, 100, red,
        maroon);
  }
}

class CampTargetPanel implements TargetPanelRenderer {
  @override
  void render(Resource resource, Terminal terminal) {
    var interaction = resource.interaction as CampInteraction;
    // Framing Box
    Draw.frame(terminal, 0, 0, terminal.width, terminal.height);
    Draw.box(terminal, 2, 1, 3, 3);

    // Camp image
    terminal.drawGlyph(3, 2, resource.appearance);
    terminal.writeAt(5, 2, resource.name);

    // Amount collected
    terminal.writeAt(1, 5, "Cactus");
    terminal.writeAt(9, 5, interaction.count.toString());
    var meterColors =
        TriPhaseColor(fore: red, back: maroon, complete: sherwood);
    Draw.chunkedMeter(terminal, 12, 5, terminal.width - 13, interaction.count,
        interaction.max, meterColors);
  }
}

class Resource {
  final Game game;

  final ResourceType _type;
  ResourceType get type => _type;

  final Vec _pos;
  Vec get pos => _pos;

  late final int quality;

  TileType get tile => _type.defaultTile;

  Glyph get appearance => _type.appearance;

  String get name => _type.name;

  bool get solid => _type.solid;

  final Interaction _interaction;
  Interaction get interaction => _interaction;

  ActionResult interact(Actor actor) {
    return _interaction.interact(this, actor);
  }

  void renderTargetPanel(Terminal terminal) =>
      _type.renderTargetPanel(this, terminal);

  // A private constructor. The only way to create a resource is via [ResourceType.newResource()].
  Resource._(this.game, this._type, this._pos, this._interaction) {
    quality = Random().nextInt(100);
  }
}

/// A single kind of [Resource] in the game.
class ResourceType {
  static final reed = ResourceType(
      'reed',
      VecGlyph.fromVec(Vec(27, 7), sherwood, gold),
      TileTypes.sand1,
      false,
      () => NoOpInteraction(),
      HarvestTargetPanel());

  static final cactus = ResourceType(
      'cactus',
      VecGlyph.fromVec(Vec(29, 4), peaGreen, gold),
      TileTypes.sand1,
      true,
      () => CactusInteraction(),
      HarvestTargetPanel());

  static final camp = ResourceType(
      'camp',
      VecGlyph.fromVec(Vec(3, 7), peaGreen, gold),
      TileTypes.flagstoneWall,
      true,
      () => CampInteraction(),
      CampTargetPanel());

  static final craftingSpot = ResourceType(
      'crafting spot',
      VecGlyph.fromVec(Vec(3, 7), peaGreen, gold),
      TileTypes.flagstoneWall,
      true,
      () => CraftingInteraction(),
      NoTargetPanel());

  // This could be a generic "pack" but then we'd need the concept of a
  // ResourceType...type. E.g. we'd need to parametrize the pack at creation
  // with a resource type (a pack OF cactus).
  static final cactusPack = ResourceType(
      'cactusPack2',
      VecGlyph.fromVec(Vec(29, 4), peaGreen, gold),
      TileTypes.sand1,
      true,
      () => NoOpInteraction(),
      NoTargetPanel());

  static final desert = [reed, cactus];

  final bool solid;

  final Interaction Function() _interaction;

  final TargetPanelRenderer _panelRenderer;

  ResourceType(this.name, this.appearance, this.defaultTile, this.solid,
      this._interaction, this._panelRenderer);

  Resource newResource(Game game, Vec pos) {
    var interaction = _interaction();
    return Resource._(game, this, pos, interaction);
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
