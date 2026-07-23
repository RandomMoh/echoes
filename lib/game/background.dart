import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'echoes_game.dart';

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
    final paint = Paint()..isAntiAlias = false;
    final cameraPos = game.camera.viewfinder.position;
    
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
