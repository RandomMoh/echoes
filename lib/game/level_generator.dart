import 'dart:math';

class LevelGenerator {
  static List<String> generateLevel(int difficulty) {
    // difficulty: 0 to 3
    final random = Random();
    
    // Level constraints based on difficulty
    int levelLength = 80 + (difficulty * 40); // 80, 120, 160, 200
    int maxGap = 2 + difficulty; // 2, 3, 4, 5
    if (maxGap > 4) maxGap = 4; // mathematical cap for jump distance is 5.8, but 4 feels safe and challenging
    
    int maxJumpHeight = 3;
    
    // Map dimensions
    int height = 24; // Generous height for verticality
    int width = levelLength;
    
    // Initialize empty map
    List<List<String>> map = List.generate(height, (_) => List.filled(width, '.'));
    
    // Bottom death floor
    for (int x = 0; x < width; x++) {
      map[height - 1][x] = '#';
      map[height - 2][x] = '^';
    }
    
    // Start platform
    int currentX = 0;
    int currentY = 16;
    
    // Spawn point and start platform
    map[currentY - 1][currentX + 2] = '@';
    for (int i = 0; i < 5; i++) {
      map[currentY][currentX + i] = '#';
    }
    
    currentX += 5;
    
    while (currentX < width - 10) {
      // Determine gap
      int gap = random.nextInt(maxGap) + 1;
      
      // Determine height change
      // -2 (down 2) to +3 (up 3)
      // Note: smaller Y is higher up on screen
      int heightChange = random.nextInt(6) - 2;
      
      // Cap max jump height (upwards is negative Y)
      if (heightChange > maxJumpHeight) heightChange = maxJumpHeight;
      
      currentY -= heightChange;
      
      // Keep within bounds
      if (currentY < 4) currentY = 4;
      if (currentY > height - 6) currentY = height - 6; // Leave space for death floor
      
      currentX += gap;
      
      // Determine platform width
      int platformWidth = random.nextInt(4) + 3; // 3 to 6
      if (currentX + platformWidth > width - 10) {
        platformWidth = (width - 10) - currentX;
      }
      
      // Place platform
      for (int i = 0; i < platformWidth; i++) {
        map[currentY][currentX + i] = '#';
      }
      
      // Checkpoints & Crystals
      if (random.nextDouble() < 0.1) {
        map[currentY - 1][currentX + platformWidth ~/ 2] = 'C';
      } else if (random.nextDouble() < 0.3) {
        map[currentY - 1][currentX + platformWidth ~/ 2] = '+';
      }
      
      currentX += platformWidth;
    }
    
    // End platform
    int gapToEnd = random.nextInt(3) + 1;
    currentX += gapToEnd;
    for (int i = currentX; i < width; i++) {
      map[currentY][i] = '#';
    }
    
    // Goal
    map[currentY - 1][width - 3] = '*';
    
    // Convert to List<String>
    List<String> result = [];
    for (int y = 0; y < height; y++) {
      result.add(map[y].join(''));
    }
    
    return result;
  }
}
