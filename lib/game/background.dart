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
            _random.nextDouble() * 2000 - 500,
            _random.nextDouble() * 1000 - 200,
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

    for (var star in _stars) {
      double drawX = star.position.x - (cameraPos.x * (star.speed / 50.0));
      double drawY = star.position.y - (cameraPos.y * (star.speed / 50.0));

      paint.color = Colors.white.withValues(alpha: star.brightness);
      canvas.drawRect(Rect.fromLTWH(drawX, drawY, star.size, star.size), paint);
    }
  }
}
