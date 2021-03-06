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
  CactusInteraction call() => CactusInteraction();

  @override
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Cactus");

    var player = actor as Player;

    var stage = resource.game.stage;
    stage.removeResource(resource);

    player.carrying = resource;

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
  // TODO: PUT BACK TO 3! 1 is just for testing purposes.
  int max = 1;

  int quality = 0;

  CampInteraction call() => CampInteraction();

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
      var newResource = player.carrying!;
      player.carrying = null;
      if (count == max) {
        // TODO: Maybe let the player REPLACE an existing resource here.
        return ActionResult.failure;
      } else {
        quality = newQuality(newResource);
        count++;
      }
    }
    return ActionResult.success;
  }

  int newQuality(Resource resource) {
    return ((quality * count) + resource.quality) ~/ (count + 1);
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

class CraftingInteraction implements Interaction {
  final List<ResourceType> requiredResourceTypes;
  // TODO: We won't really produce most of the time, these will be bespoke interactions to improve something the player owns.

  final ResourceType produces;

  int resourceIndex = 0;
  List<bool> resourceDeposited;

  static Interaction newBoatCrafting() {
    return CraftingInteraction(
        [ResourceType.cactusPack, ResourceType.cactusPack], ResourceType.boat);
  }

  CraftingInteraction(this.requiredResourceTypes, this.produces)
      : resourceDeposited =
            List<bool>.filled(requiredResourceTypes.length, false);

  @override
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] Crafting");

    var player = actor as Player;

    // Crafter is full. Produce product.
    if (resourceIndex == requiredResourceTypes.length) {
    }

    // Crafter is not full. See if the player can contribute.
    if (player.carrying != null) {
      if (player.carrying!.type == requiredResourceTypes[resourceIndex]) {
        resourceDeposited[resourceIndex] = true;
        ++resourceIndex;

        player.carrying = null;
        return ActionResult.success;
      } else {
        // Report to the player that they've got the wrong pack somehow.
        return ActionResult.failure;
      }
    }

    return ActionResult.success;
  }
}

class NoOpInteraction implements Interaction {
  @override
  ActionResult interact(Resource resource, Actor actor) {
    print("[Interact] NoOP");
    return ActionResult.success;
  }

  NoOpInteraction call() => NoOpInteraction();
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
    var height = 8;

    // Framing Box
    Draw.frame(terminal, 0, 0, terminal.width, height);
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
  static final height = 9;
  static final qualityRow = 7;
  static final meterColors =
      TriPhaseColor(fore: red, back: maroon, complete: peaGreen);

  @override
  void render(Resource resource, Terminal terminal) {
    var interaction = resource.interaction as CampInteraction;

    // Framing Box
    Draw.frame(terminal, 0, 0, terminal.width, height);
    Draw.box(terminal, 2, 1, 3, 3);

    // Camp image
    terminal.drawGlyph(3, 2, resource.appearance);
    terminal.writeAt(5, 2, resource.name);

    // Amount collected
    terminal.writeAt(1, 5, "Cactus");
    terminal.writeAt(9, 5, interaction.count.toString());
    Draw.chunkedMeter(terminal, 12, 5, terminal.width - 13, interaction.count,
        interaction.max, meterColors);

    // Quality meter
    var carrying = resource.game.player.carrying;

    terminal.writeAt(1, qualityRow, "Quality");
    if (carrying != null) {
      var newQuality = interaction.newQuality(resource.game.player.carrying!);

      terminal.writeAt(
          8, qualityRow, "(${newQuality.toString()})", Color.lightGreen);

      Draw.thinMeter(terminal, 12, qualityRow, terminal.width - 13,
          interaction.quality, 100, meterColors, newQuality);
    } else {
      terminal.writeAt(9, qualityRow, interaction.quality.toString());
      Draw.thinMeter(terminal, 12, qualityRow, terminal.width - 13,
          interaction.quality, 100);
    }
  }
}

class CraftingTargetPanel extends TargetPanelRenderer {
  @override
  void render(Resource resource, Terminal terminal) {
    var interaction = resource.interaction as CraftingInteraction;

    Draw.frame(terminal, 0, 0, terminal.width, 5);
    terminal.writeAt(2, 0, "Crafting");

    for (var i = 0; i < interaction.requiredResourceTypes.length; ++i) {
      var resourceType = interaction.requiredResourceTypes[i];
      var leftPos = 6 + (i * 3);

      // Row showing the resources needed to craft and whether they've been deposited.
      terminal.writeAt(1, 2, "Cost");
      var resourceDeposited = interaction.resourceDeposited[i];

      var borderColor = resourceDeposited ? Color.white : Color.darkGray;
      Draw.box(terminal, leftPos, 1, 3, 3, borderColor);

      double blendPct = resourceDeposited ? 0 : 0.6;
      terminal.drawGlyph(leftPos + 1, 2,
          resourceType.appearance.blend(Color.darkGray, blendPct));
    }
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
      NoOpInteraction(),
      HarvestTargetPanel());

  static final cactus = ResourceType(
      'cactus',
      VecGlyph.fromVec(Vec(29, 4), peaGreen, gold),
      TileTypes.sand1,
      true,
      CactusInteraction(),
      HarvestTargetPanel());

  static final camp = ResourceType(
      'camp',
      VecGlyph.fromVec(Vec(3, 7), peaGreen, gold),
      TileTypes.flagstoneWall,
      true,
      CampInteraction(),
      CampTargetPanel());

  static final craftingSpot = ResourceType(
      'crafting spot',
      VecGlyph.fromVec(Vec(11, 0), brown, gold),
      TileTypes.box,
      true,
      CraftingInteraction.newBoatCrafting,
      CraftingTargetPanel());

  static final boat = ResourceType(
      'boat',
      VecGlyph.fromVec(Vec(11, 0), brown, gold),
      TileTypes.box,
      true,
      NoOpInteraction(),
      NoTargetPanel());

  // This could be a generic "pack" but then we'd need the concept of a
  // ResourceType...type. E.g. we'd need to parametrize the pack at creation
  // with a resource type (a pack OF cactus).
  static final cactusPack = ResourceType(
      'cactusPack',
      VecGlyph.fromVec(Vec(29, 4), peaGreen, gold),
      TileTypes.sand1,
      true,
      NoOpInteraction(),
      NoTargetPanel());

  static final desert = [reed, cactus, craftingSpot];

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
