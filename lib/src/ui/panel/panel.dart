import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';

abstract class Panel {
  Rect? _bounds;

  bool get isVisible => _bounds != null;

  Rect get bounds => _bounds!;

  void hide() {
    _bounds = null;
  }

  void show(Rect bounds) {
    _bounds = bounds;
  }

  void render(Terminal terminal) {
    if (!isVisible) return;
    renderPanel(terminal.rect(bounds.x, bounds.y, bounds.width, bounds.height));
  }

  void renderPanel(Terminal terminal);
}
