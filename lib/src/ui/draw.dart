import 'dart:convert';

import 'package:lands/src/hues.dart';
import 'package:malison/malison.dart';

class Draw {
  static void frame(Terminal terminal, int x, int y, int width, int height,
      [Color? color]) {
    _box(terminal, x, y, width, height, color, "╒", "═", "╕", "│", "└", "─",
        "┘");
  }

  static void box(Terminal terminal, int x, int y, int width, int height,
      [Color? color]) {
    _box(terminal, x, y, width, height, color, "┌", "─", "┐", "│", "└", "─",
        "┘");
  }

  static void doubleBox(Terminal terminal, int x, int y, int width, int height,
      [Color? color]) {
    _box(terminal, x, y, width, height, color, "╔", "═", "╗", "║", "╚", "═",
        "╝");
  }

  static void _box(
      Terminal terminal,
      int x,
      int y,
      int width,
      int height,
      Color? color,
      String topLeft,
      String top,
      String topRight,
      String vertical,
      String bottomLeft,
      String bottom,
      String bottomRight) {
    color ??= darkCoolGray;
    var bar = vertical + " " * (width - 2) + vertical;
    for (var row = y + 1; row < y + height - 1; row++) {
      terminal.writeAt(x, row, bar, color);
    }

    var topRow = topLeft + top * (width - 2) + topRight;
    var bottomRow = bottomLeft + bottom * (width - 2) + bottomRight;
    terminal.writeAt(x, y, topRow, color);
    terminal.writeAt(x, y + height - 1, bottomRow, color);
  }

  /// Draws a progress bar to reflect [value]'s range between `0` and [max].
  /// Has a couple of special tweaks: the bar will only be empty if [value] is
  /// exactly `0`, otherwise it will at least show a sliver. Likewise, the bar
  /// will only be full if [value] is exactly [max], otherwise at least one
  /// half unit will be missing.
  static void meter(
      Terminal terminal, int x, int y, int width, int value, int max,
      [Color? fore, Color? back]) {
    assert(max != 0);

    fore ??= red;
    back ??= maroon;

    var barWidth = (width * 2 * value / max).round();

    // Edge cases, don't show an empty or full bar unless actually at the min
    // or max.
    if (barWidth == 0 && value > 0) barWidth = 1;
    if (barWidth == width * 2 && value < max) barWidth = width * 2 - 1;

    for (var i = 0; i < width; i++) {
      var char = CharCode.space;
      if (i < barWidth ~/ 2) {
        char = CharCode.fullBlock;
      } else if (i < (barWidth + 1) ~/ 2) {
        char = CharCode.leftHalfBlock;
      }
      terminal.drawChar(x + i, y, char, fore, back);
    }
  }

  static void thinMeter(
      Terminal terminal, int x, int y, int width, int value, int max,
      [Color? fore, Color? back]) {
    assert(max != 0);
    fore ??= red;
    back ??= maroon;

    var barWidth = (width * value / max).round();

    // Edge cases, don't show an empty or full bar unless we're all the
    // way empty or full.
    if (barWidth == 0 && value > 0) barWidth = 1;
    if (barWidth == width && value < max) barWidth = width - 1;

    for (var i = 0; i < width; i++) {
      var color = i < barWidth ? fore : back;
      terminal.drawChar(x + i, y, CharCode.lowerHalfBlock, color);
    }
  }

  static void chunkedMeter(
      Terminal terminal, int x, int y, int width, int value, int max,
      [TriPhaseColor? colors]) {
    assert(max != 0);
    var fore = colors != null ? colors.fore : red;
    var back = colors != null ? colors.back : maroon;

    var barWidth = (width * value / max).round();
    var chunkWidth = (width / max).round();
    // In cases where the width is not divisible evenly by the chunk size the
    // last chunk will be slightly smaller.

    // Edge cases, don't show an empty or full bar unless we're all the
    // way empty or full.
    if (barWidth == 0 && value > 0) barWidth = 1;
    if (barWidth == width && value < max) barWidth = width - 1;

    for (var i = 0; i < width; i++) {
      if (barWidth == width && colors?.complete != null) fore = Color.green;
      var color = i < barWidth ? fore : back;

      // At the end of a chunk draw only the left half of the block
      if ((i + 1) % chunkWidth == 0) {
        // Ensure the trailing half-block is filled
        if ((i - 1) < barWidth) color = fore;
        terminal.drawChar(x + i, y, CharCode.leftHalfBlock, color);
      } else {
        terminal.drawChar(x + i, y, CharCode.fullBlock, color);
      }
    }
  }
}
