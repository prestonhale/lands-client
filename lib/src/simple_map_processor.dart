import "dart:io";

import 'package:lands/src/map.dart';

List<Cell> getMap() {
  File('map').readAsString().then((String contents) {
    print('FileContents\n');
    print(contents);
  });
  return [Cell.wall, Cell.wall, Cell.open, Cell.wall, Cell.wall];
}