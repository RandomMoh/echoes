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
import 'heart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EchoesGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Player player;
  double playerStartX = 0;
  int currentLevelIndex = 0;
  final ValueNotifier<int> livesNotifier = ValueNotifier<int>(5);
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> highScoreNotifier = ValueNotifier<int>(0);

  final ValueNotifier<String> buttonSizeNotifier = ValueNotifier<String>('Big');
  final ValueNotifier<String> buttonStyleNotifier = ValueNotifier<String>(
    'Square',
  );

  late SharedPreferences prefs;

  static const double gravity = 2000;
  static const double tileSize = 32;

  EchoesGame()
    : super(
        camera: CameraComponent.withFixedResolution(width: 800, height: 450),
      );

  @override
  Color backgroundColor() => const Color(0xFF18181B);

  late AudioPool jumpPool;
  late AudioPool echoPool;
  late AudioPool deathPool;
  late AudioPool checkpointPool;
  late AudioPool winPool;

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

    world.add(StarfieldBackground());

    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('bgm.wav', volume: 0.3);

    await loadLevel();
  }

  Future<void> loadLevel() async {
    world.removeAll(world.children.query<StaticPlatform>());
    world.removeAll(world.children.query<Spike>());
    world.removeAll(world.children.query<Goal>());
    world.removeAll(world.children.query<Checkpoint>());
    world.removeAll(world.children.query<Player>());

    livesNotifier.value = 5;

    final levelMap = LevelData.generate(currentLevelIndex);

    for (int y = 0; y < levelMap.length; y++) {
      String row = levelMap[y];
      int startX = -1;

      for (int x = 0; x <= row.length; x++) {
        String char = x < row.length ? row[x] : '';

        if (char == '#') {
          if (startX == -1) startX = x;
        } else {
          if (startX != -1) {
            double w = (x - startX) * tileSize;
            world.add(
              StaticPlatform(
                position: Vector2(startX * tileSize, y * tileSize),
                size: Vector2(w, tileSize),
              ),
            );
            startX = -1;
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

    camera.follow(player, horizontalOnly: false, verticalOnly: false);
  }

  void nextLevel() {
    currentLevelIndex++;
    loadLevel();
  }

  void movePlayerLeft() => player.moveLeft();
  void movePlayerRight() => player.moveRight();
  void stopPlayer() => player.stopMoving();
  void jumpPlayer() => player.jump();

  @override
  void update(double dt) {
    super.update(dt);
    try {
      int posScore = ((player.position.x - playerStartX) / 10).toInt();
      if (posScore < 0) posScore = 0;
      int newScore = (currentLevelIndex * 2000) + posScore;
      scoreNotifier.value = newScore;

      if (newScore > highScoreNotifier.value) {
        highScoreNotifier.value = newScore;
        prefs.setInt('high_score', newScore);
      }
    } catch (e) {}
  }
}
