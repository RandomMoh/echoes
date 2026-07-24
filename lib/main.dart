import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'theme.dart';
import 'game/echoes_game.dart';
import 'ui/main_menu.dart';
import 'ui/hud.dart';
import 'ui/pause_menu.dart';
import 'ui/settings_menu.dart';
import 'ui/release_notes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WakelockPlus.enable();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

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
          game: EchoesGame()..pauseEngine(),
          overlayBuilderMap: {
            'mainMenu': (_, game) => MainMenu(game: game),
            'hud': (_, game) => GameHUD(game: game),
            'pause': (_, game) => PauseMenu(game: game),
            'settings': (_, game) => SettingsMenu(game: game),
            'releaseNotes': (_, game) => ReleaseNotesMenu(game: game),
          },
          initialActiveOverlays: const ['mainMenu'],
        ),
      ),
    );
  }
}
