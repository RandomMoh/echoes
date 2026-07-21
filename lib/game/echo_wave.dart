import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EchoWave extends PositionComponent {
  double radius = 0;
  final double maxRadius;
  final double speed;

  EchoWave({
    required Vector2 position,
    this.maxRadius = 1500,
    this.speed = 1200,
  }) : super(position: position, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    radius += speed * dt;
    if (radius >= maxRadius) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    double opacity = 1.0 - (radius / maxRadius).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(Offset.zero, radius, paint);
  }
}
