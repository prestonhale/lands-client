import '../../hues.dart';
import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart' as malison;

class Tile {
  TileType type = TileType.uninitialized;
}

// A "kind" of tile. Actual game tiles are represented by [Tile]. This class
// is mostly constructed via [_TileBuilder].
class TileType {
  // Type of tile when first constructed
  static final uninitialized =
      TileType("uninitialized", malison.CharGlyph.clear, false);

  final String name;
  final Object appearance;
  final bool canEnter;

  TileType(this.name, this.appearance, this.canEnter);
}

// Repository of pre-initialized tiles
class TileTypes {
  // Debug
  static final error = tile("error", Vec(0, 0), purple).closed();

  // Empty

  // General
  static final sea = tile("sea", Vec(23, 7), blue, darkBlue).closed();

  // Desert
  static final sand1 = tile("sand1", Vec(14, 7), warmGray, gold).open();
  static final sand2 = tile("sand2", Vec(13, 7), warmGray, gold).open();
  static final reed = tile("reed", Vec(27, 7), sherwood, gold).open();
  static final water = tile("water", Vec(23, 7), lightBlue, blue).closed();
  static final cacti = tile("cacti", Vec(29, 4), peaGreen, gold).closed();

  // Forest

  static _TileBuilder tile(String name, Vec vec, malison.Color fore,
          [malison.Color? back]) =>
      _TileBuilder(name, vec, fore, back);
}

class _TileBuilder {
  final String name;
  final List<malison.Glyph> glyphs;

  factory _TileBuilder(String name, Object location, malison.Color fore,
      [malison.Color? back]) {
    back ??= darkerCoolGray;

    // CharGlyph
    if (location is String || location is int) {
      var charCode =
          location is int ? location : (location as String).codeUnitAt(0);
      return _TileBuilder._(
          name, malison.CharGlyph.fromCharCode(charCode, fore, back));

      // VecGlyph
    } else if (location is Vec) {
      var vec = location as Vec;
      return _TileBuilder._(name, malison.VecGlyph.fromVec(vec, fore, back));
    } else {
      throw "'Location' parameter must be an int, char, or vec.";
    }
  }

  _TileBuilder._(this.name, malison.Glyph glyph) : glyphs = [glyph];

  // Finalize tile saying whether a character can enter or not.
  TileType open() => _finalize(true);
  TileType closed() => _finalize(false);

  TileType _finalize(bool canEnter) {
    return TileType(name, glyphs.length == 1 ? glyphs.first : glyphs, canEnter);
  }
}
