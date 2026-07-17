import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'theme.dart';
import 'game/echoes_game.dart';
import 'ui/main_menu.dart';
import 'ui/hud.dart';
import 'ui/pause_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Keep screen alive
  WakelockPlus.enable();

  // Force landscape mode for platformer
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Hide system UI (immersive mode)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const EchoesApp());
}

class EchoesApp extends StatelessWidget {
  const EchoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echoes',
      theme: EchoesTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: EchoesTheme.background,
        body: GameWidget<EchoesGame>(
          game: EchoesGame()..pauseEngine(), // Starts paused on Main Menu
          overlayBuilderMap: {
            'mainMenu': (_, game) => MainMenu(game: game),
            'hud': (_, game) => GameHUD(game: game),
            'pause': (_, game) => PauseMenu(game: game),
          },
          initialActiveOverlays: const ['mainMenu'],
        ),
      ),
    );
  }
}
