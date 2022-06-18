import 'package:malison/malison.dart';

import 'package:lands/src/ui/panel/panel.dart';
import 'package:lands/src/ui/draw.dart';

class ResourcePanel extends Panel {

  @override
  void renderPanel(Terminal terminal) {
    Draw.frame(terminal, 0, 0, terminal.width, terminal.height);
  }
}
