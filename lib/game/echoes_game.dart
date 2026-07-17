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

class EchoesGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Player player;
  int currentLevelIndex = 0;

  static const double gravity = 2000;
  static const double tileSize = 32;

  EchoesGame() : super(camera: CameraComponent.withFixedResolution(width: 800, height: 450));

  @override
  Color backgroundColor() => const Color(0xFF18181B); // Charcoal Ink background

  late AudioPool jumpPool;
  late AudioPool echoPool;
  late AudioPool deathPool;
  late AudioPool checkpointPool;
  late AudioPool winPool;

  @override
  Future<void> onLoad() async {
    // Setup camera viewfinder
    camera.viewfinder.anchor = Anchor.center;
    
    // Preload audio using AudioPools for zero latency
    jumpPool = await FlameAudio.createPool('jump.wav', maxPlayers: 4);
    echoPool = await FlameAudio.createPool('echo.wav', maxPlayers: 2);
    deathPool = await FlameAudio.createPool('death.wav', maxPlayers: 1);
    checkpointPool = await FlameAudio.createPool('checkpoint.wav', maxPlayers: 1);
    winPool = await FlameAudio.createPool('win.wav', maxPlayers: 1);
    
    // Add immersive background
    world.add(StarfieldBackground());

    await loadLevel();
  }

  Future<void> loadLevel() async {
    // Clear existing level components
    world.removeAll(world.children.query<StaticPlatform>());
    world.removeAll(world.children.query<Spike>());
    world.removeAll(world.children.query<Goal>());
    world.removeAll(world.children.query<Checkpoint>());
    world.removeAll(world.children.query<Player>());

    if (currentLevelIndex >= LevelData.levels.length) {
      // Game Over / Win State
      currentLevelIndex = 0; // loop for now
    }

    final levelMap = LevelData.levels[currentLevelIndex];
    
    // Parse level
    for (int y = 0; y < levelMap.length; y++) {
      String row = levelMap[y];
      for (int x = 0; x < row.length; x++) {
        String char = row[x];
        Vector2 pos = Vector2(x * tileSize, y * tileSize);
        Vector2 size = Vector2(tileSize, tileSize);

        if (char == '#') {
          world.add(StaticPlatform(position: pos, size: size));
        } else if (char == '^') {
          world.add(Spike(position: pos, size: size));
        } else if (char == '*') {
          world.add(Goal(position: pos, size: size));
        } else if (char == 'C') {
          world.add(Checkpoint(position: pos, size: size));
        } else if (char == '+') {
          world.add(Crystal(position: pos, size: size));
        } else if (char == '@') {
          player = Player(position: pos);
          world.add(player);
        }
      }
    }

    // Add boundaries (optional)
    world.add(ScreenHitbox());

    // Camera follow player
    camera.follow(player, horizontalOnly: false, verticalOnly: false);
  }

  void nextLevel() {
    currentLevelIndex++;
    loadLevel();
  }

  // Player controls triggered by UI
  void movePlayerLeft() => player.moveLeft();
  void movePlayerRight() => player.moveRight();
  void stopPlayer() => player.stopMoving();
  void jumpPlayer() => player.jump();
}
