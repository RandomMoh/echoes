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
  double crumbleTimer = 0.5; // 0.5 seconds to jump off
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

    if (player.isEchoing && distance < player.echoRadius) {
      opacity = 1.0;
    }

    if (!hasCrumbled) {
      opacity = (opacity - dt * 0.5).clamp(0.0, 1.0);
    }

    if (isCrumbling && !hasCrumbled) {
      crumbleTimer -= dt;
      
      // Vigorous shake effect by applying a random offset
      _shakeX = (math.Random().nextDouble() - 0.5) * 8.0;

      if (crumbleTimer <= 0) {
        hasCrumbled = true;
        opacity = 0.0;
        // Trigger a global screen shake when the platform collapses
        game.shakeCamera(0.2, 5.0);
        
        // Disable collision
        children.query<RectangleHitbox>().forEach((hitbox) {
          hitbox.collisionType = CollisionType.inactive;
        });
      }
    }
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player && !isCrumbling && !hasCrumbled) {
      // Only crumble if the player lands ON it (player's bottom intersects platform's top)
      if (other.velocity.y >= 0 && other.position.y + other.size.y <= position.y + 10) {
        isCrumbling = true;
        opacity = 1.0; // Stay lit while crumbling so the player sees it
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0.0) return;

    canvas.save();
    if (isCrumbling && !hasCrumbled) {
      canvas.translate(_shakeX, 0);
    }

    final paint = Paint()
      ..isAntiAlias = false
      // Distinctly color the crumbling platform (e.g. orange-ish tint to stand out as dangerous if lit)
      ..color = const Color(0xFFFF6B6B).withValues(alpha: opacity) 
      ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), paint);

    final borderPaint = Paint()
      ..isAntiAlias = false
      ..color = Colors.black.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Add a crumbling texture pattern
    canvas.drawRect(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), borderPaint);
    
    canvas.drawLine(const Offset(8, 2), Offset(14, size.y - 2), borderPaint);
    canvas.drawLine(Offset(size.x - 10, 2), Offset(size.x - 18, size.y - 2), borderPaint);

    canvas.restore();
  }
}
