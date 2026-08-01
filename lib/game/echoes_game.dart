import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'level.dart';
import 'spike.dart';
import 'goal.dart';
import 'checkpoint.dart';
import 'levels_data.dart';
import 'crystal.dart';
import 'background.dart';
import 'moving_platform.dart';
import 'crumbling_platform.dart';
import 'heart.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class EchoesGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Player player;
  double playerStartX = 0;
  int currentLevelIndex = 0;
  final ValueNotifier<int> livesNotifier = ValueNotifier<int>(5);
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  int crystalScore = 0;

  void addCrystalScore(int points) {
    crystalScore += points;
  }

  final ValueNotifier<int> highScoreNotifier = ValueNotifier<int>(0);

  final ValueNotifier<String> buttonSizeNotifier = ValueNotifier<String>('Big');
  final ValueNotifier<String> buttonStyleNotifier = ValueNotifier<String>(
    'Square',
  );

  late SharedPreferences prefs;

  static const double gravity = 2000;
  static const double tileSize = 32;

  EchoesGame() : super(camera: CameraComponent());

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera.viewfinder.zoom = size.x / 800.0;
  }

  @override
  Color backgroundColor() => const Color(0xFF18181B);

  late AudioPool jumpPool;
  late AudioPool echoPool;
  late AudioPool deathPool;
  late AudioPool checkpointPool;
  late AudioPool winPool;
  late AudioPool dashPool;
  late AudioPool crystalPool;

  int _currentBgmLevel = -1;
  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;

  void shakeCamera(double duration, double intensity) {
    _shakeTimer = duration;
    _shakeIntensity = intensity;
  }

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;

    prefs = await SharedPreferences.getInstance();
    highScoreNotifier.value = prefs.getInt('high_score') ?? 0;
    buttonSizeNotifier.value = prefs.getString('button_size') ?? 'Big';
    buttonStyleNotifier.value = prefs.getString('button_style') ?? 'Square';

    jumpPool = await FlameAudio.createPool('jump.wav', maxPlayers: 4);
    echoPool = await FlameAudio.createPool('echo.wav', maxPlayers: 2);
    deathPool = await FlameAudio.createPool('death.wav', maxPlayers: 1);
    checkpointPool = await FlameAudio.createPool(
      'checkpoint.wav',
      maxPlayers: 1,
    );
    winPool = await FlameAudio.createPool('win.wav', maxPlayers: 1);
    dashPool = await FlameAudio.createPool('dash.wav', maxPlayers: 2);
    crystalPool = await FlameAudio.createPool('crystal.wav', maxPlayers: 4);

    world.add(StarfieldBackground());

    FlameAudio.bgm.initialize();

    await loadLevel();
  }

  Future<void> loadLevel() async {
    final toRemove = world.children.where((c) => c is! StarfieldBackground).toList();
    for (final child in toRemove) {
      child.removeFromParent();
    }

    livesNotifier.value = 5;

    int targetBgmLevel = 1;
    if (currentLevelIndex >= 8)
      targetBgmLevel = 3;
    else if (currentLevelIndex >= 4)
      targetBgmLevel = 2;

    if (targetBgmLevel != _currentBgmLevel) {
      _currentBgmLevel = targetBgmLevel;
      if (targetBgmLevel == 1) {
        FlameAudio.bgm.play('bgm.ogg', volume: 0.3);
      } else if (targetBgmLevel == 2) {
        FlameAudio.bgm.play('bgm_level2.ogg', volume: 0.35);
      } else {
        FlameAudio.bgm.play('bgm_level3.ogg', volume: 0.4);
      }
    }

    final levelMap = LevelData.generate(currentLevelIndex);

    for (int y = 0; y < levelMap.length; y++) {
      String row = levelMap[y];
      int startX = -1;
      String currentType = '';

      for (int x = 0; x <= row.length; x++) {
        String char = x < row.length ? row[x] : '';

        if (char == '#' || char == '%') {
          if (startX == -1) {
            startX = x;
            currentType = char;
          } else if (currentType != char) {
            double w = (x - startX) * tileSize;
            if (currentType == '#') {
              world.add(
                StaticPlatform(
                  position: Vector2(startX * tileSize, y * tileSize),
                  size: Vector2(w, tileSize),
                ),
              );
            } else if (currentType == '%') {
              world.add(
                CrumblingPlatform(
                  position: Vector2(startX * tileSize, y * tileSize),
                  size: Vector2(w, tileSize),
                ),
              );
            }
            startX = x;
            currentType = char;
          }
        } else {
          if (startX != -1) {
            double w = (x - startX) * tileSize;
            if (currentType == '#') {
              world.add(
                StaticPlatform(
                  position: Vector2(startX * tileSize, y * tileSize),
                  size: Vector2(w, tileSize),
                ),
              );
            } else if (currentType == '%') {
              world.add(
                CrumblingPlatform(
                  position: Vector2(startX * tileSize, y * tileSize),
                  size: Vector2(w, tileSize),
                ),
              );
            }
            startX = -1;
            currentType = '';
          }

          if (x < row.length) {
            Vector2 pos = Vector2(x * tileSize, y * tileSize);
            Vector2 sizeV = Vector2(tileSize, tileSize);
            if (char == '^') {
              world.add(Spike(position: pos, size: sizeV));
            } else if (char == '*') {
              world.add(Goal(position: pos, size: sizeV));
            } else if (char == 'C') {
              world.add(Checkpoint(position: pos, size: sizeV));
            } else if (char == '+') {
              world.add(Crystal(position: pos, size: sizeV));
            } else if (char == 'h') {
              world.add(HeartPickup(position: Vector2(x * 32.0, y * 32.0)));
            } else if (char == '@') {
              player = Player(position: pos);
              playerStartX = pos.x;
              world.add(player);

              world.add(
                StaticPlatform(
                  position: Vector2(pos.x, pos.y + tileSize),
                  size: sizeV,
                ),
              );
            } else if (char == 'w') {
              // Ignore 'w', it's part of a vertical wall handled by 'W'
            } else if (char == 'W') {
              int wh = 1;
              while (y + wh < levelMap.length && levelMap[y + wh][x] == 'w') {
                wh++;
              }
              world.add(StaticPlatform(
                position: pos,
                size: Vector2(2 * tileSize, wh * tileSize),
              ));
            } else if (char == 'V' || char == 'H') {
              world.add(
                MovingPlatform(
                  position: pos,
                  size: Vector2(tileSize * 2, tileSize),
                  axis: char == 'V'
                      ? MovementAxis.vertical
                      : MovementAxis.horizontal,
                ),
              );
            }
          }
        }
      }
    }

    world.add(ScreenHitbox());

    camera.stop();
    camera.follow(player, horizontalOnly: false, verticalOnly: false);
  }

  void nextLevel() {
    currentLevelIndex++;
    crystalScore = 0;
    loadLevel();
  }

  void movePlayerLeft() => player.moveLeft();
  void movePlayerRight() => player.moveRight();
  void stopPlayer() => player.stopMoving();
  void jumpPlayer() => player.jump();
  void dashPlayer() => player.dash();

  @override
  void update(double dt) {
    super.update(dt);
    try {
      int posScore = ((player.position.x - playerStartX) / 10).toInt();
      if (posScore < 0) posScore = 0;
      int newScore = (currentLevelIndex * 2000) + posScore + crystalScore;
      scoreNotifier.value = newScore;

      if (newScore > highScoreNotifier.value) {
        highScoreNotifier.value = newScore;
        prefs.setInt('high_score', newScore);
      }
    } catch (e) {}

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;

      camera.viewfinder.position += Vector2(
        (math.Random().nextDouble() - 0.5) * _shakeIntensity,
        (math.Random().nextDouble() - 0.5) * _shakeIntensity,
      );
    }
  }
}
