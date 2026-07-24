import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../game/echoes_game.dart';

class ReleaseNotesMenu extends StatelessWidget {
  final EchoesGame game;

  const ReleaseNotesMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        height: 350,
        color: EchoesTheme.background,
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: EchoesTheme.surface, width: 4),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UPDATE 1.4.3',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '* ADDED PROGRESSIVE 8-BIT BGM\n'
                        '* ADDED NEW DASH MECHANIC (JUMP IN MID-AIR)\n'
                        '* ADDED NEW DASH SOUND EFFECT\n'
                        '* ADDED NEW CRYSTAL SOUND EFFECT\n'
                        '* REWRITTEN LEVEL GENERATOR FOR DASH GAPS\n'
                        '* FIXED JUMP INPUT DELAY\n'
                        '* FIXED LEVEL TRANSITION MEMORY LEAKS',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 12,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    game.overlays.remove('releaseNotes');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    color: Colors.transparent,
                    child: Text(
                      '[ CLOSE ]',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: EchoesTheme.surface,
                        fontSize: 14,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(begin: 1.0, end: 0.0, duration: 800.ms),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
