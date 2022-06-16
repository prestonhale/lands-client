import 'package:piecemeal/piecemeal.dart';
import 'package:malison/malison.dart';
import 'package:lands/src/ui/panel/panel.dart';

class StagePanel extends Panel {
  int _frame = 0;

  /// The portion of the [Stage] currently in view on screen.
  Rect get cameraBounds => _cameraBounds;

  late Rect _cameraBounds;

  bool update(Iterable<Event> event) {
    _frame++;

    return true;
  }

  void renderPanel(Terminal terminal) {
    _positionCamera();
    for (var pos in _cameraBounds) {
      int? char;
      var fore = Color.black;
      var back = Color.black;
    }
  }

  void _positionCamera(Vec size) {
    var _game = _gameScreen.game;

    var camera = game.player.pos - size ~/ 2;
    camera = cameraRange.clamp(camera)
  }
}
