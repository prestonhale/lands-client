import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';

abstract class Panel {
  Rect? _bounds;
  bool isVisible = true;

  /// Tracks whether this panel should appear above other panels on this screen.
  // This will have a performance implication.
  // Don't force the game to rerender these glyphs just ensure they're not
  // superseded by OTHER panels changed glyphs.
  bool pinToTop = false;

  /// The bounding box for the panel.
  ///
  /// This can only be called if the panel is visible.
  Rect get bounds => _bounds!;

  void hide(Terminal terminal) {
    if (_bounds != null) {
      // Mark the glyphs we were responsible for displaying as empty.
      for (var pos in _bounds!) {
        terminal.drawGlyph(pos.x, pos.y, CharGlyph.clear);
      }
      isVisible = false;
    }
  }

  void show() {
    isVisible = true;
  }

  void setBounds(Rect bounds) {
    _bounds = bounds;
  }

  void render(Terminal terminal) {
    if (!isVisible) return;
    renderPanel(terminal.rect(bounds.x, bounds.y, bounds.width, bounds.height));
  }

  void renderPanel(Terminal terminal);
}
