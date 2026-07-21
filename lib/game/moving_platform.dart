import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'level.dart';

enum MovementAxis { horizontal, vertical }

class MovingPlatform extends StaticPlatform {
  final MovementAxis axis;
  final double moveDistance;
  final double speed;
  Vector2 velocity = Vector2.zero();
  
  late Vector2 _startPosition;
  double _time = 0;

  MovingPlatform({
    required Vector2 position,
    required Vector2 size,
    required this.axis,
    this.moveDistance = 96.0, // 3 tiles
    this.speed = 2.0,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _startPosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    
    Vector2 prevPosition = position.clone();

    if (axis == MovementAxis.vertical) {
      position.y = _startPosition.y + math.sin(_time * speed) * moveDistance;
    } else {
      position.x = _startPosition.x + math.sin(_time * speed) * moveDistance;
    }
    
    // Calculate instantaneous velocity for friction/riding logic
    velocity = (position - prevPosition) / dt;
  }
  
  @override
  void render(Canvas canvas) {
    // Add a slight visual distinction for moving platforms
    super.render(canvas);
    
    if (opacity <= 0.0) return;
    
    final paint = Paint()
      ..isAntiAlias = false
      ..color = Colors.cyanAccent.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    // Draw an inner glowing border
    canvas.drawRect(Rect.fromLTWH(4, 4, size.x - 8, size.y - 8), paint);
  }
}
