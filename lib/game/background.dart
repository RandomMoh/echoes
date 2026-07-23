import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'echoes_game.dart';

const List<Color> kLevelColors = [
  Color(0xFF18181B), // Level 0: near-black zinc
  Color(0xFF1E1B4B), // Level 1: deep indigo
  Color(0xFF052E16), // Level 2: deep forest green
  Color(0xFF450A0A), // Level 3: deep crimson
  Color(0xFF1C1917), // Level 4: warm charcoal
  Color(0xFF0F172A), // Level 5: midnight slate
  Color(0xFF172554), // Level 6: deep navy
  Color(0xFF2E1065), // Level 7: dark violet
  Color(0xFF1C1917), // Level 8: stone black
  Color(0xFF064E3B), // Level 9: deep emerald
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
          Vector2(
            _random.nextDouble() * 850,
            _random.nextDouble() * 500,
          ),
          _random.nextDouble() > 0.9 ? 2.0 : 1.0,
          _random.nextDouble() * 10 + 2,
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
    final levelIdx = game.currentLevelIndex % kLevelColors.length;
    final bgColor = kLevelColors[levelIdx];

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(
      Rect.fromLTWH(cameraPos.x - 425, cameraPos.y - 250, 850, 500),
      bgPaint,
    );

    final paint = Paint()..isAntiAlias = false;
    double leftEdge = cameraPos.x - 425.0;
    double topEdge = cameraPos.y - 250.0;

    for (var star in _stars) {
      double parallaxX = star.position.x - (cameraPos.x * (star.speed / 50.0));
      double parallaxY = star.position.y - (cameraPos.y * (star.speed / 50.0));

      double drawX = leftEdge + ((parallaxX - leftEdge) % 850.0);
      if (drawX < leftEdge) drawX += 850.0;

      double drawY = topEdge + ((parallaxY - topEdge) % 500.0);
      if (drawY < topEdge) drawY += 500.0;

      paint.color = Colors.white.withValues(alpha: star.brightness);
      canvas.drawRect(Rect.fromLTWH(drawX, drawY, star.size, star.size), paint);
    }
  }
}
