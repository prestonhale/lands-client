import '../../hues.dart';
import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';
import 'package:lands/src/engine/core/math.dart';

class Tile {
  TileType type = TileType.uninitialized;

  @override
  String toString() {
    return "Tile Type: ${type.name}";
  }
}

// A "kind" of tile. Actual game tiles are represented by [Tile]. This class
// is mostly constructed via [_TileBuilder].
class TileType {
  // Type of tile when first constructed
  static final uninitialized =
      TileType("uninitialized", CharGlyph.clear, false);

  final String name;
  final Object appearance;
  final bool canEnter;

  TileType(this.name, this.appearance, this.canEnter);

  @override
  String toString() => "$name";
}

// Repository of pre-initialized tiles
class TileTypes {
  // TODO: Let some tiles have transparent backgrounds. Only actors have
  //  transparent backgrounds?
  // Debug

  static final error = tile("error", Vec(0, 0), purple).solid();

  // Empty

  // General
  static final sea = tile("sea", Vec(23, 7), blue, darkBlue)
      .animate(40, 0.7, darkBlue, darkBlue)
      .solid();
  static final shield = tile("shield", Vec(23, 7), blue, darkBlue).solid();

  // Walls.
  static final flagstoneWall =
      tile("flagstone wall", Vec(17, 5), lightWarmGray, warmGray).solid();

  static final sandstoneWall =
      tile("sandstone wall", Vec(17, 5), sandal, tan).solid();

  static final graniteWall =
      tile("granite wall", Vec(17, 5), coolGray, darkCoolGray).solid();

  static final sandstone1 = tile("sandstone", Vec(18, 5), sandal, gold)
      .blend(0.0, darkCoolGray, darkerCoolGray)
      .open();

  static final granite1 = tile("granite", Vec(18, 5), coolGray, darkCoolGray)
      .blend(0.0, darkCoolGray, darkerCoolGray)
      .solid();

  // Desert
  static final sand1 = tile("sand1", Vec(14, 7), warmGray, gold).open();
  static final sand2 = tile("sand2", Vec(13, 7), warmGray, gold).open();
  static final water = tile("water", Vec(23, 7), lightBlue, blue)
      .animate(40, 0.3, darkBlue, darkerCoolGray)
      .solid();

  static final desert = [
    error,
    sandstoneWall,
    sandstone1,
    graniteWall,
    granite1,
    sea,
    sand1,
    sand2,
    water,
  ];

  // Forest

  static _TileBuilder tile(String name, Vec vec, Color fore, [Color? back]) =>
      _TileBuilder(name, vec, fore, back);
}

class _TileBuilder {
  final String name;
  final List<Glyph> glyphs;

  factory _TileBuilder(String name, Object location, Color fore,
      [Color? back]) {
    back ??= darkerCoolGray;

    // CharGlyph
    if (location is String || location is int) {
      var charCode =
          location is int ? location : (location as String).codeUnitAt(0);
      return _TileBuilder._(name, CharGlyph.fromCharCode(charCode, fore, back));

      // VecGlyph
    } else if (location is Vec) {
      var vec = location as Vec;
      return _TileBuilder._(name, VecGlyph.fromVec(vec, fore, back));
    } else {
      throw "'Location' parameter must be an int, char, or vec.";
    }
  }

  _TileBuilder._(this.name, Glyph glyph) : glyphs = [glyph];

  _TileBuilder blend(double amount, Color fore, Color back) {
    var glyph = glyphs.first as VecGlyph;
    glyphs[0] = VecGlyph.fromVec(glyph.vec, glyph.fore.blend(fore, amount),
        glyph.back.blend(fore, amount));
    return this;
  }

  _TileBuilder animate(int count, double maxMix, Color fore, Color back) {
    var glyph = glyphs.first;
    for (var i = 1; i < count; i++) {
      var mixedFore =
          glyph.fore.blend(fore, lerpDouble(i, 0, count, 0.0, maxMix));
      var mixedBack =
          glyph.back.blend(back, lerpDouble(i, 0, count, 0.0, maxMix));

      if (glyph is VecGlyph) {
        glyphs.add(VecGlyph.fromVec(glyph.vec, mixedFore, mixedBack));
      } else {
        throw ("Can't animate non-vector glyphs.");
      }
    }
    return this;
  }

  // Finalize tile saying whether a character can enter or not.
  TileType open() => _finalize(true);
  TileType solid() => _finalize(false);

  TileType _finalize(bool canEnter) {
    return TileType(name, glyphs.length == 1 ? glyphs.first : glyphs, canEnter);
  }
}
