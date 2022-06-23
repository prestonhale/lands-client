import 'dart:math';

import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/stage/tile.dart';

class Resource {
  final ResourceType _type;

  final Vec _pos;

  late final int quality;

  Vec get pos => _pos;

  TileType get tile => _type.tile;

  Resource(this._type, this._pos) {
    quality = Random().nextInt(100);
  }
}

/// A single kind of [Resource] in the game.
class ResourceType {
  static final reed = ResourceType(TileTypes.reed);
  static final cactus = ResourceType(TileTypes.cacti);

  static final desert = [reed, cactus];

  /// May change. Right now just represent all resources as a flat tile.
  /// This DOES couple the engine directly to the "stage".
  final TileType tile;

  ResourceType(this.tile);
}
