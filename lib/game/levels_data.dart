import 'level_generator.dart';

class LevelData {
  static List<String> generate(int levelIndex) {
    return LevelGenerator.generateLevel(levelIndex);
  }
}
