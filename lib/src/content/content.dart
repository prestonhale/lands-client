import 'world.dart';

GameContent createContent() {
  return GameContent();
}

const island_width = 20;

class GameContent {
  Iterable<String> buildWorld(){
    return TutorialIsland(island_width).generateIsland();
  }
}