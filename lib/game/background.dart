import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'echoes_game.dart';

const List<Color> kLevelColors = [
  Color(0xFF111114), // level 1: dark grey
  Color(0xFF14141B), // level 2: dull slate
  Color(0xFF0C120E), // level 3: dull green
  Color(0xFF161111), // level 4: dull red
  Color(0xFF151312), // level 5: dull brown
  Color(0xFF101216), // level 6: dull blue
  Color(0xFF12141A), // level 7: dull indigo
  Color(0xFF16131C), // level 8: dull purple
  Color(0xFF141212), // level 9: dark grey
  Color(0xFF0C1210), // level 10: dull teal
];

class Star {
  Vector2 position;
  double size;
  double speed;
  double brightness;

  Star(this.position, this.size, this.speed, this.brightness);
}

class StarfieldBackground extends PositionComponent
    with HasGameReference<EchoesGame> {
  final List<Star> _stars = [];
  final int count = 200;
  final math.Random _random = math.Random();

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < count; i++) {
      _stars.add(
        Star(
          Vector2(_random.nextDouble() * 850, _random.nextDouble() * 500),
          _random.nextDouble() > 0.9 ? 2.0 : 1.0,
          _random.nextDouble() * 3 + 1,
          _random.nextDouble() * 0.5 + 0.1,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (var star in _stars) {
      star.brightness += (math.sin(game.currentTime() * star.speed) * 0.01);
      star.brightness = star.brightness.clamp(0.1, 0.6);
    }
  }

  @override
  void render(Canvas canvas) {
    final cameraPos = game.camera.viewfinder.position;
    final zoom = game.camera.viewfinder.zoom;
    final screenW = game.size.x / zoom;
    final screenH = game.size.y / zoom;
    final levelIdx = game.currentLevelIndex % kLevelColors.length;
    final bgColor = kLevelColors[levelIdx];

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(
      Rect.fromLTWH(
        cameraPos.x - screenW / 2,
        cameraPos.y - screenH / 2,
        screenW,
        screenH,
      ),
      bgPaint,
    );

    final paint = Paint()..isAntiAlias = false;
    double leftEdge = cameraPos.x - screenW / 2;
    double topEdge = cameraPos.y - screenH / 2;

    for (var star in _stars) {
      double parallaxX = star.position.x - (cameraPos.x * (star.speed / 800.0));
      double parallaxY =
          star.position.y - (cameraPos.y * (star.speed / 2000.0));

      double drawX = leftEdge + ((parallaxX - leftEdge) % screenW);
      if (drawX < leftEdge) drawX += screenW;

      double drawY = topEdge + ((parallaxY - topEdge) % screenH);
      if (drawY < topEdge) drawY += screenH;

      paint.color = Colors.white.withValues(alpha: star.brightness);
      canvas.drawRect(Rect.fromLTWH(drawX, drawY, star.size, star.size), paint);
    }
  }
}
