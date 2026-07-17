import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Goal extends PositionComponent with CollisionCallbacks {
  double _time = 0;

  Goal({
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
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // A pulsing beacon
    double pulse = (math.sin(_time * 5) + 1) / 2; // 0 to 1
    
    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.amber.withValues(alpha: 0.5 + (pulse * 0.5))
      ..style = PaintingStyle.fill;

    // Draw a pixelated portal (staggered blocks)
    double step = size.x / 4;
    canvas.drawRect(Rect.fromLTWH(step, 0, step * 2, size.y), paint);
    canvas.drawRect(Rect.fromLTWH(0, step, size.x, size.y - step * 2), paint);

    final inner = Paint()..isAntiAlias = false..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(step * 1.5, step * 1.5, step, step), inner);
  }
}
