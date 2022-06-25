import 'dart:math';

import 'package:malison/malison.dart';
import 'package:piecemeal/piecemeal.dart';
import 'package:lands/src/engine/stage/tile.dart';
import 'package:lands/src/hues.dart';

class Resource {
  final ResourceType _type;

  ResourceType get type => _type;

  final Vec _pos;

  late final int quality;

  Vec get pos => _pos;

  TileType get tile => _type.defaultTile;

  Glyph get appearance => _type.appearance;
  
  String get name => _type.name;

  Resource(this._type, this._pos) {
    quality = Random().nextInt(100);
  }
}

/// A single kind of [Resource] in the game.
class ResourceType {
  static final reed = ResourceType(
      'reed', VecGlyph.fromVec(Vec(27, 7), sherwood, gold), TileTypes.sand1);
  static final cactus = ResourceType(
      'cactus', VecGlyph.fromVec(Vec(29, 4), peaGreen, gold), TileTypes.sand1);
  
  static final camp = ResourceType(
      'camp', VecGlyph.fromVec(Vec(3, 7), peaGreen, gold), TileTypes.flagstoneWall);

  static final desert = [reed, cactus];

  /// May change. Right now just represent all resources as a flat tile.
  /// Eventually there will be a glyph on top of the tile that represents the
  /// actual resource, mainly so that the resource can be removed and the tile
  /// remain.
  /// This DOES couple the engine directly to the "stage".
  final String name;
  final Glyph appearance;
  final TileType defaultTile;

  ResourceType(this.name, this.appearance, this.defaultTile);

  @override
  String toString() => "${defaultTile}";
}
