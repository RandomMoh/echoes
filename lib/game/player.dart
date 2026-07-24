import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'echoes_game.dart';
import 'level.dart';
import 'echo_wave.dart';
import 'crystal.dart';
import 'heart.dart';
import 'checkpoint.dart';
import 'spike.dart';
import 'goal.dart';
import 'moving_platform.dart';

class DashGhost extends PositionComponent {
  double life;
  double maxLife;
  int facing;
  bool isBlinking;

  DashGhost({
    required Vector2 position,
    required this.facing,
    required this.isBlinking,
    this.life = 0.3,
  }) : maxLife = 0.3,
       super(position: position, size: Vector2(24, 24), anchor: Anchor.center);

  @override
  void update(double dt) {
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..isAntiAlias = false;
    paint.color = Colors.white.withValues(alpha: (life / maxLife) * 0.5);

    double breatheOffset = 0;

    canvas.drawRect(
      Rect.fromLTWH(0, breatheOffset, size.x, 20 - breatheOffset),
      paint,
    );

    paint.color = const Color(0xFF18181B).withValues(alpha: (life / maxLife) * 0.5);
    double eyeY = 4 + breatheOffset;
    double eyeHeight = isBlinking ? 2 : 6;
    double eyeWidth = 4;

    if (facing == 1) {
      canvas.drawRect(Rect.fromLTWH(12, eyeY, eyeWidth, eyeHeight), paint);
      canvas.drawRect(Rect.fromLTWH(20, eyeY, eyeWidth, eyeHeight), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, eyeY, eyeWidth, eyeHeight), paint);
      canvas.drawRect(Rect.fromLTWH(8, eyeY, eyeWidth, eyeHeight), paint);
    }

    double scarfStartX = facing == 1 ? 4.0 : size.x - 8.0;
    double scarfY = 12.0 + breatheOffset;

    for (int i = 0; i < 3; i++) {
      double segmentX = scarfStartX - (facing * (i * 6));
      canvas.drawRect(Rect.fromLTWH(segmentX, scarfY, 6, 6), paint);
    }

    paint.color = Colors.white.withValues(alpha: (life / maxLife) * 0.5);
    if (facing == 1) {
      canvas.drawRect(Rect.fromLTWH(4, 18, 6, 4), paint);
      canvas.drawRect(Rect.fromLTWH(14, 18, 6, 4), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(14, 18, 6, 4), paint);
      canvas.drawRect(Rect.fromLTWH(4, 18, 6, 4), paint);
    }
  }
}

class DustParticle extends PositionComponent {
  Vector2 velocity;
  double life;
  double maxLife;

  DustParticle({
    required Vector2 position,
    required this.velocity,
    this.life = 0.5,
  }) : maxLife = 0.5,
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
    final paint = Paint()
      ..color = Colors.white.withValues(
        alpha: (life / maxLife).clamp(0.0, 1.0),
      );
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

  double echoRadius = 0.0;
  bool isEchoing = false;

  Vector2 _currentCheckpoint = Vector2.zero();

  int facing = 1;
  double _time = 0;
  double _blinkTimer = 2.0;
  bool _isBlinking = false;
  double _particleTimer = 0;

  double _jumpBufferTimer = 0.0;
  double _coyoteTimer = 0.0;
  double _invincibilityTimer = 0.0;

  bool hasDashed = false;
  bool isDashing = false;
  double _dashTimer = 0.0;
  double _ghostTimer = 0.0;

  StaticPlatform? currentPlatform;

  Player({required Vector2 position})
    : super(position: position, size: Vector2(24, 24), anchor: Anchor.center) {
    _spawnPoint = position.clone();
    _currentCheckpoint = position.clone();
    _previousPosition = position.clone();
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
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyW ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        jump();
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void jump() {
    if (isOnGround) {
      velocity.y = -jumpForce;
      isOnGround = false;
      _wasOnGround = false;
      _coyoteTimer = 0;
      _jumpBufferTimer = 0;
      game.jumpPool.start(volume: 0.5);
    } else if (!hasDashed && !isDashing) {
      isDashing = true;
      hasDashed = true;
      _dashTimer = 0.15; 
      velocity.y = 0;
      velocity.x = facing * 800;
      game.echoPool.start(volume: 0.7);
      
      // Camera shake
      game.camera.viewfinder.position = Vector2((math.Random().nextDouble() - 0.5) * 15, (math.Random().nextDouble() - 0.5) * 15);
    } else {
      _jumpBufferTimer = 0.15;
    }
  }

  void moveLeft() => _horizontalInput = -1;
  void moveRight() => _horizontalInput = 1;
  void stopMoving() => _horizontalInput = 0;

  void triggerEcho() {
    isEchoing = true;
    echoRadius = 0;
    game.echoPool.start(volume: 0.6);

    game.world.add(
      EchoWave(position: position + size / 2, maxRadius: 1500, speed: 1200),
    );
  }

  Vector2 _previousPosition = Vector2.zero();
  bool _wasOnGround = false;

  @override
  void update(double dt) {
    if (dt > 0.033) dt = 0.033;

    if (isOnGround) {
      _coyoteTimer = 0.1;
      hasDashed = false;
    } else {
      _coyoteTimer -= dt;
    }

    if (_jumpBufferTimer > 0) {
      _jumpBufferTimer -= dt;
      if (_coyoteTimer > 0) {
        velocity.y = -jumpForce;
        isOnGround = false;
        _wasOnGround = false;
        _coyoteTimer = 0;
        _jumpBufferTimer = 0;
        game.jumpPool.start(volume: 0.5);
      }
    }

    _previousPosition = position.clone();

    if (_wasOnGround && currentPlatform is MovingPlatform) {
      position.x += (currentPlatform as MovingPlatform).velocity.x * dt;
    }

    _wasOnGround = isOnGround;
    isOnGround = false;
    currentPlatform = null;
    super.update(dt);

    velocity.x = _horizontalInput * moveSpeed;
    if (_horizontalInput != 0) {
      facing = _horizontalInput;
    }

    if (isDashing) {
      _dashTimer -= dt;
      velocity.y = 0; 
      velocity.x = facing * 800; 
      
      _ghostTimer -= dt;
      if (_ghostTimer <= 0) {
        game.world.add(
          DashGhost(
            position: position.clone(),
            facing: facing,
            isBlinking: _isBlinking,
          )
        );
        _ghostTimer = 0.03;
      }

      if (_dashTimer <= 0) {
        isDashing = false;
        velocity.x = _horizontalInput * moveSpeed; 
        game.camera.viewfinder.position = Vector2.zero();
      }
    } else {
      velocity.y += EchoesGame.gravity * dt;
      velocity.y = velocity.y.clamp(-jumpForce, maxFallSpeed);
    }

    position += velocity * dt;

    _time += dt;
    _blinkTimer -= dt;

    if (_invincibilityTimer > 0) {
      _invincibilityTimer -= dt;
    }

    if (_blinkTimer <= 0) {
      _isBlinking = !_isBlinking;
      _blinkTimer = _isBlinking ? 0.15 : 2.0 + math.Random().nextDouble() * 3.0;
    }

    if (_horizontalInput != 0 && isOnGround) {
      _particleTimer -= dt;
      if (_particleTimer <= 0) {
        game.world.add(
          DustParticle(
            position: position.clone()..y += size.y / 2,
            velocity: Vector2(
              -_horizontalInput * 40.0,
              -10.0 + (math.Random().nextDouble() - 0.5) * 20,
            ),
            life: 0.3 + math.Random().nextDouble() * 0.3,
          ),
        );
        _particleTimer = 0.05;
      }
    }

    if (isEchoing) {
      echoRadius += 1200 * dt;
      if (echoRadius > 1500) {
        isEchoing = false;
      }
    }

    if (position.y > 2000) {
      respawn();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (isRemoving || other.isRemoving) return;

    if (other is StaticPlatform) {
      _resolvePlatformCollision(intersectionPoints, other);
    } else if (other is Spike) {
      if (_invincibilityTimer <= 0) die();
    } else if (other is Checkpoint && !other.isActive) {
      game.checkpointPool.start(volume: 0.7);
      other.activate();
      _currentCheckpoint = other.position.clone();
    } else if (other is Goal) {
      game.winPool.start(volume: 0.8);
      game.nextLevel();
    } else if (other is HeartPickup) {
      if (game.livesNotifier.value < 5) {
        game.livesNotifier.value++;
        game.checkpointPool.start(volume: 0.8);
      }
      other.collect();
    } else if (other is Crystal && !other.isCollected) {
      other.collect();
      hasDashed = false;
      game.echoPool.start(volume: 0.5);
      game.addCrystalScore(500);
    }
    super.onCollision(intersectionPoints, other);
  }

  void _resolvePlatformCollision(Set<Vector2> points, StaticPlatform platform) {
    final overlapX =
        (size.x / 2 + platform.size.x / 2) -
        (position.x - (platform.position.x + platform.size.x / 2)).abs();
    final overlapY =
        (size.y / 2 + platform.size.y / 2) -
        (position.y - (platform.position.y + platform.size.y / 2)).abs();

    if (overlapX <= 0 || overlapY <= 0) return;

    final platformTop = platform.position.y;
    final platformBottom = platform.position.y + platform.size.y;
    final platformLeft = platform.position.x;
    final platformRight = platform.position.x + platform.size.x;

    final prevPlayerBottom = _previousPosition.y + size.y / 2;
    final prevPlayerTop = _previousPosition.y - size.y / 2;
    final prevPlayerRight = _previousPosition.x + size.x / 2;
    final prevPlayerLeft = _previousPosition.x - size.x / 2;

    bool fromAbove = prevPlayerBottom <= platformTop + 12.0;
    bool fromBelow = prevPlayerTop >= platformBottom - 4.0;
    bool fromLeft = prevPlayerRight <= platformLeft + 4.0;
    bool fromRight = prevPlayerLeft >= platformRight - 4.0;

    if (fromAbove && velocity.y >= 0) {
      position.y = platformTop - size.y / 2;
      if (!_wasOnGround && !isOnGround) triggerEcho();
      isOnGround = true;
      currentPlatform = platform;
      velocity.y = 0;
    } else if (fromBelow && velocity.y < 0) {
      position.y = platformBottom + size.y / 2;
      velocity.y = 0;
    } else if (fromLeft && velocity.x > 0) {
      position.x = platformLeft - size.x / 2;
      velocity.x = 0;
    } else if (fromRight && velocity.x < 0) {
      position.x = platformRight + size.x / 2;
      velocity.x = 0;
    } else {
      if (overlapX < overlapY) {
        if (position.x < platform.position.x + platform.size.x / 2) {
          position.x -= overlapX;
          velocity.x = 0;
        } else {
          position.x += overlapX;
          velocity.x = 0;
        }
      } else {
        if (position.y < platform.position.y + platform.size.y / 2) {
          position.y -= overlapY;
          if (!_wasOnGround && !isOnGround) triggerEcho();
          isOnGround = true;
          currentPlatform = platform;
          velocity.y = 0;
        } else {
          position.y += overlapY;
          if (velocity.y < 0) velocity.y = 0;
        }
      }
    }
  }

  void die() {
    if (_invincibilityTimer > 0) return;
    game.deathPool.start(volume: 0.8);
    game.livesNotifier.value--;

    if (game.livesNotifier.value <= 0) {
      game.currentLevelIndex = 0;
      game.loadLevel();
      return;
    } else {
      position = _currentCheckpoint.clone();
      _previousPosition = position.clone();
      velocity = Vector2.zero();
      isOnGround = false;
      _wasOnGround = false;
      _invincibilityTimer = 1.5;
    }
    triggerEcho();
  }

  void respawn() {
    die();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..isAntiAlias = false;

    double breatheOffset = (isOnGround && velocity.x == 0)
        ? (math.sin(_time * 5) * 1.5)
        : 0;

    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, breatheOffset, size.x, 20 - breatheOffset),
      paint,
    );

    paint.color = const Color(0xFF18181B);
    double eyeY = 4 + breatheOffset;
    double eyeHeight = _isBlinking ? 2 : 6;
    double eyeWidth = 4;

    if (facing == 1) {
      canvas.drawRect(Rect.fromLTWH(12, eyeY, eyeWidth, eyeHeight), paint);
      canvas.drawRect(Rect.fromLTWH(20, eyeY, eyeWidth, eyeHeight), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, eyeY, eyeWidth, eyeHeight), paint);
      canvas.drawRect(Rect.fromLTWH(8, eyeY, eyeWidth, eyeHeight), paint);
    }

    double scarfStartX = facing == 1 ? 4.0 : size.x - 8.0;
    double scarfY = 12.0 + breatheOffset;

    int segments = 3;
    double timeOffset = _time * 15;

    for (int i = 0; i < segments; i++) {
      double segmentX = scarfStartX - (facing * (i * 6));
      double waveY = ((math.sin(timeOffset - i) * 3).roundToDouble());
      waveY -= (velocity.y * 0.005).roundToDouble();
      canvas.drawRect(Rect.fromLTWH(segmentX, scarfY + waveY, 6, 6), paint);
    }

    paint.color = Colors.white;
    double foot1Y = 20;
    double foot2Y = 20;

    if (isOnGround) {
      if (velocity.x != 0) {
        foot1Y = 20 - math.max(0.0, math.sin(_time * 25) * 4);
        foot2Y = 20 - math.max(0.0, -math.sin(_time * 25) * 4);
      } else {
        foot1Y = 20;
        foot2Y = 20;
      }
    } else {
      foot1Y = 18;
      foot2Y = 18;
    }

    if (facing == 1) {
      canvas.drawRect(Rect.fromLTWH(4, foot1Y, 6, 4), paint);
      canvas.drawRect(Rect.fromLTWH(14, foot2Y, 6, 4), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(14, foot1Y, 6, 4), paint);
      canvas.drawRect(Rect.fromLTWH(4, foot2Y, 6, 4), paint);
    }
  }
}
