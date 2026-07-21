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

      int minGap = 1;
      if (difficulty > 3) minGap = 2;
      if (difficulty > 7) minGap = 3;
      
      int gap = random.nextInt(maxGap - minGap + 1) + minGap;
      
      int heightChange = random.nextInt(6) - 2;
      if (heightChange > maxJumpHeight) heightChange = maxJumpHeight;
      if (difficulty > 5 && random.nextBool()) heightChange -= 1; // Steeper drops

      // Intelligent safety: don't combine max gap with max height jump
      if (gap == 4 && heightChange > 2) {
        heightChange = 2;
      }
      
      int oldY = currentY;
      currentY -= heightChange;
      
      if (currentY < 4) currentY = 4;
      if (currentY > height - 6) currentY = height - 6; // Leave space for death floor
      
      currentX += gap;
      
      // Spawn moving platforms in large gaps at high difficulty
      if (difficulty > 8 && gap >= 3 && random.nextDouble() < 0.4) {
        int movingX = currentX - (gap ~/ 2) - 1;
        int movingY = (oldY + currentY) ~/ 2;
        map[movingY][movingX] = random.nextBool() ? 'V' : 'H';
      }
      
      int minWidth = 3;
      int maxWidth = 6;
      if (difficulty > 2) maxWidth = 5;
      if (difficulty > 4) maxWidth = 4;
      if (difficulty > 6) minWidth = 2;
      if (difficulty > 8) { minWidth = 2; maxWidth = 3; }
      
      int platformWidth = random.nextInt(maxWidth - minWidth + 1) + minWidth;
      
      if (currentX + platformWidth > width - 10) {
        platformWidth = (width - 10) - currentX;
      }
      if (platformWidth < 2) platformWidth = 2; // Failsafe
      
      for (int i = 0; i < platformWidth; i++) {
        map[currentY][currentX + i] = '#';
      }
      
      // Intelligent obstacles: vertical slabs or spikes
      if (difficulty > 8 && platformWidth >= 5 && random.nextDouble() < 0.3) {
        int slabX = currentX + (platformWidth ~/ 2);
        map[currentY - 1][slabX] = '#';
        map[currentY - 2][slabX] = '#'; // 2-block high wall
      } else if (difficulty > 3 && platformWidth >= 4 && random.nextDouble() < min(0.4, difficulty * 0.05)) {
        int spikeX = currentX + (platformWidth ~/ 2);
        // Ensure we don't overwrite the checkpoint
        map[currentY - 1][spikeX] = '^';
      }

      if (random.nextDouble() < 0.1) {
        // Place checkpoint at the end of the platform to avoid the middle spike
        map[currentY - 1][currentX + platformWidth - 1] = 'C';
      } else if (random.nextDouble() < 0.3) {
        map[currentY - 3][currentX + platformWidth ~/ 2] = '+';
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
