import 'package:flutter/material.dart';
import '../theme.dart';
import '../game/echoes_game.dart';

class PauseMenu extends StatelessWidget {
  final EchoesGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EchoesTheme.background.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () {
                game.overlays.remove('pause');
                game.overlays.add('hud');
                game.resumeEngine();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: EchoesTheme.background,
                  border: Border.all(color: EchoesTheme.surface, width: 4),
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  'RESUME',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: EchoesTheme.surface,
                    fontSize: 14,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
