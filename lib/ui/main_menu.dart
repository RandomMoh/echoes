import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../game/echoes_game.dart';

class MainMenu extends StatelessWidget {
  final EchoesGame game;

  const MainMenu({super.key, required this.game});

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
                    game.overlays.remove('mainMenu');
                    game.overlays.add('hud');
                    game.resumeEngine();
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
