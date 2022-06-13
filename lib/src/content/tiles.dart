import '../hues.dart';
import 'package:malison/malison.dart' as malison;

class Tile {
  TileType type = TileType.uninitialized;
}

// A "kind" of tile. Actual game tiles are represented by [Tile]. This class
// is mostly constructed via [_TileBuilder].
class TileType {
  // Type of tile when first constructed
  static final uninitialized = TileType("uninitialized", null, false);

  final String name;
  final Object? appearance;
  final bool canEnter;

  TileType(this.name, this.appearance, this.canEnter);
}

// Repository of pre-initialized tiles
class TileTypes {
  static final sand = tile("sand", "s", gold).open();

  static _TileBuilder tile(String name, Object char, malison.Color fore,
      [malison.Color? back]) =>
    _TileBuilder(name, char, fore, back);
}

class _TileBuilder {
  final String name;
  final List<malison.Glyph> glyphs;

  factory _TileBuilder(String name, Object char, malison.Color fore, [malison.Color? back]) {
    back ??= darkerCoolGray;
    var charCode = char is int ? char : (char as String).codeUnitAt(0);

    return _TileBuilder._(name, malison.Glyph.fromCharCode(charCode, fore, back));
  }

  _TileBuilder._(this.name, malison.Glyph glyph) : glyphs = [glyph];

  // Finalize tile saying whether a character can enter or not.
  TileType open() => _finalize(true);
  TileType closed() => _finalize(false);

  TileType _finalize(bool canEnter) {
    return TileType(name, glyphs.length == 1 ? glyphs.first : glyphs, canEnter);
  }

}