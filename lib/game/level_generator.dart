import 'dart:math';

class LevelGenerator {
  static List<String> generateLevel(int difficulty) {

    final random = Random();
    

    int levelLength = 80 + (difficulty * 40); // 80, 120, 160, 200
    int maxGap = 2 + difficulty; // 2, 3, 4, 5
    if (maxGap > 4) maxGap = 4; // mathematical cap for jump distance is 5.8, but 4 feels safe and challenging
    
    int maxJumpHeight = 3;
    

    int height = 24; // Generous height for verticality
    int width = levelLength;
    

    List<List<String>> map = List.generate(height, (_) => List.filled(width, '.'));
    

    for (int x = 0; x < width; x++) {
      map[height - 1][x] = '#';
      map[height - 2][x] = '^';
    }
    

    int currentX = 0;
    int currentY = 16;
    

    map[currentY - 1][currentX + 2] = '@';
    for (int i = 0; i < 5; i++) {
      map[currentY][currentX + i] = '#';
    }
    
    currentX += 5;
    
    while (currentX < width - 10) {

      int gap = random.nextInt(maxGap) + 1;
      



      int heightChange = random.nextInt(6) - 2;
      

      if (heightChange > maxJumpHeight) heightChange = maxJumpHeight;
      
      currentY -= heightChange;
      

      if (currentY < 4) currentY = 4;
      if (currentY > height - 6) currentY = height - 6; // Leave space for death floor
      
      currentX += gap;
      

      int platformWidth = random.nextInt(4) + 3; // 3 to 6
      if (currentX + platformWidth > width - 10) {
        platformWidth = (width - 10) - currentX;
      }
      

      for (int i = 0; i < platformWidth; i++) {
        map[currentY][currentX + i] = '#';
      }
      

      if (random.nextDouble() < 0.1) {
        map[currentY - 1][currentX + platformWidth ~/ 2] = 'C';
      } else if (random.nextDouble() < 0.3) {
        map[currentY - 1][currentX + platformWidth ~/ 2] = '+';
      }
      
      currentX += platformWidth;
    }
    

    int gapToEnd = random.nextInt(3) + 1;
    currentX += gapToEnd;
    for (int i = currentX; i < width; i++) {
      map[currentY][i] = '#';
    }
    

    map[currentY - 1][width - 3] = '*';
    

    List<String> result = [];
    for (int y = 0; y < height; y++) {
      result.add(map[y].join(''));
    }
    
    return result;
  }
}
