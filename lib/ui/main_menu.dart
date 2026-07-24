import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme.dart';
import '../game/echoes_game.dart';

class MainMenu extends StatefulWidget {
  final EchoesGame game;

  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    _checkReleaseNotes();
  }

  Future<void> _checkReleaseNotes() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString('last_seen_version');
    if (lastSeen != currentVersion) {
      widget.game.overlays.add('releaseNotes');
      await prefs.setString('last_seen_version', currentVersion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EchoesTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 64.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                Text(
                      'ECHOES',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        height: 1.0,
                        shadows: [
                          const Shadow(
                            color: Colors.white,
                            offset: Offset(4, 4),
                          ),
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 1.seconds)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                Text(
                  'IN THE DARK',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    letterSpacing: 4.0,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 800.ms),

                const Spacer(),

                GestureDetector(
                  onTap: () {
                    widget.game.overlays.remove('mainMenu');
                    widget.game.overlays.add('hud');
                    widget.game.resumeEngine();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    color: Colors.transparent,
                    child:
                        Text(
                              'PRESS START',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: EchoesTheme.surface,
                                    fontSize: 14,
                                    letterSpacing: 2.0,
                                  ),
                            )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .fade(begin: 1.0, end: 0.0, duration: 600.ms),
                  ),
                ).animate().fadeIn(delay: 1.seconds),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
