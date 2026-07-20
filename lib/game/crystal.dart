import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'echoes_game.dart';

class Crystal extends PositionComponent with HasGameReference<EchoesGame> {
  double _opacity = 0.0;
  double _time = 0;

  Crystal({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    
    final player = game.player;
    final center = position + size / 2;
    final distance = center.distanceTo(player.position);

    if (player.isEchoing && distance < player.echoRadius) {
      _opacity = 1.0;
    }
    
    _opacity = (_opacity - dt * 0.3).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0.0) return;
    
    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.cyanAccent.withValues(alpha: _opacity)
      ..style = PaintingStyle.fill;
      

    double cx = size.x / 2;
    double cy = size.y / 2 + math.sin(_time * 2) * 4; // float up and down
    

    canvas.drawRect(Rect.fromLTWH(cx - 4, cy - 8, 8, 16), paint);
    canvas.drawRect(Rect.fromLTWH(cx - 8, cy - 4, 16, 8), paint);
    

    if (_opacity > 0.5) {
      final sparklePaint = Paint()
        ..isAntiAlias = false
        ..color = Colors.white.withValues(alpha: _opacity);
      canvas.drawRect(Rect.fromLTWH(cx + 8, cy - 12, 4, 4), sparklePaint);
      canvas.drawRect(Rect.fromLTWH(cx - 12, cy + 8, 4, 4), sparklePaint);
    }
  }
}
