import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'player.dart';

class HeartPickup extends PositionComponent with CollisionCallbacks {
  double _time = 0;
  bool _collected = false;

  HeartPickup({required Vector2 position})
    : super(position: position, size: Vector2(32, 32));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_collected) return;
    _time += dt;

    double scaleFactor = 1.0 + math.sin(_time * 6) * 0.15;
    scale = Vector2.all(scaleFactor);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_collected) return;

    final paint = Paint()
      ..color = const Color(0xFFFF0044)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final List<List<int>> pixels = [
      [0, 1, 1, 0, 0, 1, 1, 0],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 0],
    ];

    final double pixelWidth = size.x / 8;
    final double pixelHeight = size.y / 8;

    for (int r = 0; r < pixels.length; r++) {
      for (int c = 0; c < pixels[r].length; c++) {
        if (pixels[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * pixelWidth,
              r * pixelHeight + pixelHeight,
              pixelWidth,
              pixelHeight,
            ),
            paint,
          );

          canvas.drawRect(
            Rect.fromLTWH(
              c * pixelWidth,
              r * pixelHeight + pixelHeight,
              pixelWidth,
              pixelHeight,
            ),
            Paint()
              ..color = Colors.black.withOpacity(0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0
              ..isAntiAlias = false,
          );
        }
      }
    }
  }

  void collect() {
    if (_collected) return;
    _collected = true;
    removeFromParent();
  }
}
