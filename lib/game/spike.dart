import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'echoes_game.dart';

class Spike extends PositionComponent with HasGameReference<EchoesGame>, CollisionCallbacks {
  double _opacity = 0.0;

  Spike({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {

    add(RectangleHitbox(
      position: Vector2(4, 10),
      size: Vector2(size.x - 8, size.y - 10),
    )..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final player = game.player;
    final center = position + size / 2;
    final distance = center.distanceTo(player.position);

    if (player.isEchoing && distance < player.echoRadius) {
      _opacity = 1.0;
    }
    
    _opacity = (_opacity - dt * 0.5).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0.0) return;
    
    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.white.withValues(alpha: _opacity) // Minimalist theme
      ..style = PaintingStyle.fill;
      

    double cx = size.x / 2;
    double bottom = size.y;
    
    canvas.drawRect(Rect.fromLTWH(cx - 2, bottom - 16, 4, 4), paint); // top tip
    canvas.drawRect(Rect.fromLTWH(cx - 6, bottom - 12, 12, 4), paint);
    canvas.drawRect(Rect.fromLTWH(cx - 10, bottom - 8, 20, 4), paint);
    canvas.drawRect(Rect.fromLTWH(cx - 14, bottom - 4, 28, 4), paint); // base
  }
}
