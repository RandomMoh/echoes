import 'level_generator.dart';

class LevelData {
  static List<String> generate(int levelIndex) {
    // Generate an endless progression of levels on the fly
    return LevelGenerator.generateLevel(levelIndex);
  }
}
