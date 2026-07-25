import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'echoes_game.dart';
import 'player.dart';

class CrumblingPlatform extends PositionComponent
    with HasGameReference<EchoesGame>, CollisionCallbacks {
  double opacity = 0.0;
  bool isCrumbling = false;
  bool hasCrumbled = false;
  double crumbleTimer = 1.2;
  double _shakeX = 0.0;

  CrumblingPlatform({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

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

    if (!hasCrumbled && player.isEchoing && distance < player.echoRadius) {
      opacity = 1.0;
    }

    if (!hasCrumbled) {
      opacity = (opacity - dt * 0.5).clamp(0.0, 1.0);
    }

    if (isCrumbling && !hasCrumbled) {
      crumbleTimer -= dt;

      _shakeX = (math.Random().nextDouble() - 0.5) * 8.0;

      if (crumbleTimer <= 0) {
        hasCrumbled = true;
        opacity = 0.0;

        game.shakeCamera(0.2, 5.0);

        removeFromParent();
      }
    }
  }

  void startCrumbling() {
    if (!isCrumbling && !hasCrumbled) {
      isCrumbling = true;
      opacity = 1.0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0.0) return;

    canvas.save();
    if (isCrumbling && !hasCrumbled) {
      canvas.translate(_shakeX, 0);
    }

    final paintColor = isCrumbling ? const Color(0xFFFF6B6B) : Colors.white;
    final paint = Paint()
      ..isAntiAlias = false
      ..color = paintColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), paint);

    final borderPaint = Paint()
      ..isAntiAlias = false
      ..color = Colors.black.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), borderPaint);

    canvas.drawLine(const Offset(8, 2), Offset(14, size.y - 2), borderPaint);
    canvas.drawLine(
      Offset(size.x - 10, 2),
      Offset(size.x - 18, size.y - 2),
      borderPaint,
    );

    canvas.restore();
  }
}
