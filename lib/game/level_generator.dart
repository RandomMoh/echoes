import 'dart:math';

class LevelGenerator {
  static List<String> generateLevel(int difficulty) {
    final random = Random();

    int levelLength = 80 + (difficulty * 40);
    int maxGap = 3 + difficulty;
    if (maxGap > 9) maxGap = 9;

    int maxJumpHeight = 3;

    int height = 24;
    int width = levelLength;

    List<List<String>> map = List.generate(
      height,
      (_) => List.filled(width, '.'),
    );

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
    int platformsSinceLastStar = 2;
    int platformsSinceLastHeart = 0;

    while (currentX < width - 10) {
      int minGap = 2;
      if (difficulty > 3) minGap = 4;
      if (difficulty > 7) minGap = 6;

      int gap = random.nextInt(maxGap - minGap + 1) + minGap;

      bool willHaveMovingPlatform =
          difficulty >= 4 && random.nextDouble() < 0.2;
      if (willHaveMovingPlatform) {
        gap = max(10, gap + 4);
      }

      int heightChange = random.nextInt(6) - 2;
      if (heightChange > maxJumpHeight) heightChange = maxJumpHeight;
      if (difficulty > 5 && random.nextBool()) heightChange -= 1;

      if (!willHaveMovingPlatform && gap == 4 && heightChange > 2) {
        heightChange = 2;
      }

      int oldY = currentY;
      currentY -= heightChange;

      if (currentY < 4) currentY = 4;
      if (currentY > height - 6) currentY = height - 6;

      currentX += gap;

      if (willHaveMovingPlatform) {
        int movingX = currentX - (gap ~/ 2);
        int movingY = (oldY + currentY) ~/ 2;
        map[movingY][movingX] = random.nextBool() ? 'V' : 'H';
      }

      int minWidth = 3;
      int maxWidth = 6;
      if (difficulty > 2) maxWidth = 5;
      if (difficulty > 4) maxWidth = 4;
      if (difficulty > 6) minWidth = 2;
      if (difficulty > 8) {
        minWidth = 2;
        maxWidth = 3;
      }

      int platformWidth = random.nextInt(maxWidth - minWidth + 1) + minWidth;

      if (currentX + platformWidth > width - 10) {
        platformWidth = (width - 10) - currentX;
      }
      if (platformWidth < 2) platformWidth = 2;

      bool isCrumblingPlatform = difficulty >= 4 && !willHaveMovingPlatform && random.nextDouble() < min(0.15, difficulty * 0.02);
      String platformChar = isCrumblingPlatform ? '%' : '#';

      for (int i = 0; i < platformWidth; i++) {
        map[currentY][currentX + i] = platformChar;
      }

      if (difficulty > 8 && platformWidth >= 5 && random.nextDouble() < 0.3) {
        int slabX = currentX + (platformWidth ~/ 2);
        map[currentY - 1][slabX] = platformChar;
        map[currentY - 2][slabX] = platformChar;
      } else if (difficulty > 3 &&
          platformWidth >= 4 &&
          random.nextDouble() < min(0.4, difficulty * 0.05)) {
        int spikeX = currentX + (platformWidth ~/ 2);

        map[currentY - 1][spikeX] = '^';
      }

      if (random.nextDouble() < 0.1) {
        map[currentY - 1][currentX + platformWidth - 1] = 'C';
      } else if (difficulty >= 3 && platformsSinceLastStar > 15 && random.nextDouble() < 0.2) {
        int heightOffset = random.nextBool() ? 4 : 5;
        int targetY = currentY - heightOffset;
        if (targetY < 0) targetY = 0;
        map[targetY][currentX + platformWidth ~/ 2] = '+';
        platformsSinceLastStar = 0;
      } else if (difficulty >= 5 &&
          platformsSinceLastHeart > 10 &&
          random.nextDouble() < 0.3) {
        map[currentY - 1][currentX + platformWidth ~/ 2] = 'h';
        platformsSinceLastHeart = 0;
      }

      platformsSinceLastStar++;
      platformsSinceLastHeart++;

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
