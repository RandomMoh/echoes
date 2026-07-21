import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'echoes_game.dart';

class StaticPlatform extends PositionComponent with HasGameReference<EchoesGame>, CollisionCallbacks {
  double opacity = 0.0;

  StaticPlatform({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final player = game.player;
    final center = position + size / 2;
    final distance = center.distanceTo(player.position);


    if (player.isEchoing && distance < player.echoRadius) {
      opacity = 1.0;
    }
    

    opacity = (opacity - dt * 0.5).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0.0) return;
    
    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
      

    canvas.drawRect(size.toRect(), paint);


    final borderPaint = Paint()
      ..isAntiAlias = false
      ..color = Colors.black.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), borderPaint);
  }
}
