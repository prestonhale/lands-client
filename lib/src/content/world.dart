import 'dart:convert';
import 'dart:html';
import 'package:lands/src/content/content.dart';

class World {
  static late final List<String> lines;

  static void initialize() {
    var path = 'island_layout.txt';
    HttpRequest.getString(path).then((String fileContents) {
      LineSplitter ls = LineSplitter();
      lines = ls.convert(fileContents);
    }).catchError((error) {
      print(error.toString());
    });
  }
}
