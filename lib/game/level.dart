import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'echoes_game.dart';

class StaticPlatform extends PositionComponent with HasGameReference<EchoesGame>, CollisionCallbacks {
  double _opacity = 0.0;

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

    // If the wave hits, fully illuminate
    if (player.isEchoing && distance < player.echoRadius) {
      _opacity = 1.0;
    }
    
    // Fade out slowly over time
    _opacity = (_opacity - dt * 0.5).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0.0) return;
    
    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.white.withValues(alpha: _opacity)
      ..style = PaintingStyle.fill;
      
    // Draw the box
    canvas.drawRect(size.toRect(), paint);

    // Draw an inner border for pixel art style
    final borderPaint = Paint()
      ..isAntiAlias = false
      ..color = Colors.black.withValues(alpha: _opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), borderPaint);
  }
}
