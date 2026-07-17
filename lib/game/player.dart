import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'echoes_game.dart';
import 'level.dart';
import 'echo_wave.dart';
import 'checkpoint.dart';
import 'spike.dart';
import 'goal.dart';

class DustParticle extends PositionComponent {
  Vector2 velocity;
  double life;
  double maxLife;

  DustParticle({required Vector2 position, required this.velocity, this.life = 0.5}) 
      : maxLife = 0.5,
        super(position: position, size: Vector2(4, 4), anchor: Anchor.center);

  @override
  void update(double dt) {
    position += velocity * dt;
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: (life / maxLife).clamp(0.0, 1.0));
    canvas.drawRect(size.toRect(), paint);
  }
}

class Player extends PositionComponent
    with HasGameReference<EchoesGame>, CollisionCallbacks, KeyboardHandler {
  
  static const double moveSpeed = 250;
  static const double jumpForce = 750;
  static const double maxFallSpeed = 800;

  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  int _horizontalInput = 0;

  Vector2 _spawnPoint = Vector2.zero();

  // For the echo effect
  double echoRadius = 0.0;
  bool isEchoing = false;

  // Progression & Checkpoints
  Vector2 _currentCheckpoint = Vector2.zero();

  // Animation state
  int facing = 1; // 1 for right, -1 for left
  double _time = 0;
  double _blinkTimer = 2.0;
  bool _isBlinking = false;
  double _particleTimer = 0;

  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2(24, 24), // Minimalist square
          anchor: Anchor.center,
        ) {
    _spawnPoint = position.clone();
    _currentCheckpoint = position.clone();
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _horizontalInput = 0;

    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _horizontalInput = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _horizontalInput = 1;
    }

    if (event is KeyDownEvent) {
      if ((event.logicalKey == LogicalKeyboardKey.space ||
           event.logicalKey == LogicalKeyboardKey.keyW ||
           event.logicalKey == LogicalKeyboardKey.arrowUp) &&
          isOnGround) {
        jump();
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void jump() {
    if (!isOnGround) return;
    velocity.y = -jumpForce;
    isOnGround = false;
    game.jumpPool.start(volume: 0.5);
    triggerEcho();
  }

  void moveLeft() => _horizontalInput = -1;
  void moveRight() => _horizontalInput = 1;
  void stopMoving() => _horizontalInput = 0;

  void triggerEcho() {
    isEchoing = true;
    echoRadius = 0;
    game.echoPool.start(volume: 0.6);
    
    // Spawn visual wave
    game.world.add(EchoWave(position: position + size / 2, maxRadius: 1500, speed: 1200));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Horizontal movement
    velocity.x = _horizontalInput * moveSpeed;
    if (_horizontalInput != 0) {
      facing = _horizontalInput;
    }

    // Apply gravity
    velocity.y += EchoesGame.gravity * dt;
    velocity.y = velocity.y.clamp(-jumpForce, maxFallSpeed);

    // Apply velocity
    position += velocity * dt;

    // Animation Timers
    _time += dt;
    _blinkTimer -= dt;
    if (_blinkTimer <= 0) {
      _isBlinking = !_isBlinking;
      _blinkTimer = _isBlinking ? 0.15 : 2.0 + math.Random().nextDouble() * 3.0;
    }

    // Particle Trail
    if (_horizontalInput != 0 && isOnGround) {
      _particleTimer -= dt;
      if (_particleTimer <= 0) {
         game.world.add(DustParticle(
           position: position.clone()..y += size.y / 2, // spawn at feet
           velocity: Vector2(-_horizontalInput * 40.0, -10.0 + (math.Random().nextDouble() - 0.5) * 20),
           life: 0.3 + math.Random().nextDouble() * 0.3,
         ));
         _particleTimer = 0.05; // spawn every 50ms
      }
    }

    // Update Echo effect
    if (isEchoing) {
      echoRadius += 1200 * dt; // Echo expands fast
      if (echoRadius > 1500) {
        isEchoing = false;
      }
    }

    // Death check
    if (position.y > game.size.y + 200) {
      respawn();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is StaticPlatform) {
      _resolvePlatformCollision(intersectionPoints, other);
    } else if (other is Spike) {
      die();
    } else if (other is Checkpoint && !other.isActive) {
      game.checkpointPool.start(volume: 0.7);
      other.activate();
      _currentCheckpoint = other.position.clone();
    } else if (other is Goal) {
      game.winPool.start(volume: 0.8);
      game.nextLevel();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _resolvePlatformCollision(Set<Vector2> points, StaticPlatform platform) {
    final playerCenterX = position.x;
    final playerCenterY = position.y;
    final platformCenterX = platform.position.x + platform.size.x / 2;
    final platformCenterY = platform.position.y + platform.size.y / 2;

    final overlapX = (size.x / 2 + platform.size.x / 2) - (playerCenterX - platformCenterX).abs();
    final overlapY = (size.y / 2 + platform.size.y / 2) - (playerCenterY - platformCenterY).abs();

    if (overlapX > 0 && overlapY > 0) {
      // Fix internal edge seams: if the player is falling and near the top edge, treat it as a vertical landing.
      bool isLanding = (playerCenterY < platformCenterY) && (overlapY <= 6);
      
      if (overlapX < overlapY && !isLanding) {
        // Horizontal collision
        if (playerCenterX < platformCenterX) {
          position.x -= overlapX;
        } else {
          position.x += overlapX;
        }
      } else {
        // Vertical collision
        if (playerCenterY < platformCenterY) {
          // Landing on top
          position.y -= overlapY;
          if (!isOnGround && velocity.y > 0) {
            triggerEcho();
          }
          isOnGround = true;
          velocity.y = 0;
        } else {
          // Hitting from below
          position.y += overlapY;
          if (velocity.y < 0) {
            velocity.y = 0;
          }
        }
      }
    }
  }

  void die() {
    game.deathPool.start(volume: 0.8);
    game.livesNotifier.value--;
    
    if (game.livesNotifier.value <= 0) {
      // Hard reset to level start
      game.livesNotifier.value = 5;
      position = _spawnPoint.clone();
    } else {
      // Soft reset to checkpoint
      position = _currentCheckpoint.clone();
    }
    velocity = Vector2.zero();
    triggerEcho();
  }

  void respawn() {
    die();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Pixel-art drawing style: Disable anti-aliasing
    final paint = Paint()..isAntiAlias = false;

    // Body (White Square)
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    // Eyes (Charcoal black, 2x2 or 2x4 pixels)
    paint.color = const Color(0xFF18181B);
    double eyeY = 4;
    double eyeHeight = _isBlinking ? 2 : 6;
    double eyeWidth = 4;
    
    if (facing == 1) {
      canvas.drawRect(Rect.fromLTWH(12, eyeY, eyeWidth, eyeHeight), paint);
      canvas.drawRect(Rect.fromLTWH(20, eyeY, eyeWidth, eyeHeight), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, eyeY, eyeWidth, eyeHeight), paint);
      canvas.drawRect(Rect.fromLTWH(8, eyeY, eyeWidth, eyeHeight), paint);
    }

    // Scarf (Pixelated steps)
    paint.color = const Color(0xFF18181B);
    double scarfStartX = facing == 1 ? 4.0 : size.x - 8.0;
    double scarfY = 14.0;
    
    // Calculate simple wave offsets for scarf segments
    int segments = 3;
    double timeOffset = _time * 15;
    
    for (int i = 0; i < segments; i++) {
      double segmentX = scarfStartX - (facing * (i * 6));
      // Integer math for pixelated waving
      double waveY = ((math.sin(timeOffset - i) * 3).roundToDouble());
      // Adjust slightly for falling/jumping
      waveY -= (velocity.y * 0.005).roundToDouble();
      
      canvas.drawRect(Rect.fromLTWH(segmentX, scarfY + waveY, 6, 6), paint);
    }
  }
}
