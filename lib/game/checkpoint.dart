import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class Checkpoint extends PositionComponent with CollisionCallbacks {
  bool isActive = false;

  Checkpoint({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  void activate() {
    isActive = true;
  }

  @override
  void render(Canvas canvas) {
    // Checkpoints are always dimly visible so players have something to aim for
    final paint = Paint()
      ..isAntiAlias = false
      ..color = isActive ? Colors.tealAccent.withValues(alpha: 0.8) : Colors.teal.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(size.toRect(), paint);
    
    // Draw a small inner pixel diamond if active
    if (isActive) {
      final inner = Paint()..isAntiAlias = false..color = Colors.tealAccent..style = PaintingStyle.fill;
      double cx = size.x / 2;
      double cy = size.y / 2;
      canvas.drawRect(Rect.fromLTWH(cx - 2, cy - 6, 4, 12), inner);
      canvas.drawRect(Rect.fromLTWH(cx - 6, cy - 2, 12, 4), inner);
    }
  }
}
