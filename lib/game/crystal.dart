import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'echoes_game.dart';

class Crystal extends PositionComponent with HasGameReference<EchoesGame>, CollisionCallbacks {
  double _time = 0;
  bool isCollected = false;

  Crystal({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  void collect() {
    isCollected = true;
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.fill;

    double cx = size.x / 2;
    double cy = size.y / 2 + math.sin(_time * 4) * 4;

    canvas.drawRect(Rect.fromLTWH(cx - 6, cy - 12, 12, 24), paint);
    canvas.drawRect(Rect.fromLTWH(cx - 12, cy - 6, 24, 12), paint);

    final sparklePaint = Paint()
      ..isAntiAlias = false
      ..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(cx + 10, cy - 14, 4, 4), sparklePaint);
    canvas.drawRect(Rect.fromLTWH(cx - 14, cy + 10, 4, 4), sparklePaint);
  }
}
