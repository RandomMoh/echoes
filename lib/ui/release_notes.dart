import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme.dart';
import '../game/echoes_game.dart';

class ReleaseNotesMenu extends StatefulWidget {
  final EchoesGame game;

  const ReleaseNotesMenu({super.key, required this.game});

  @override
  State<ReleaseNotesMenu> createState() => _ReleaseNotesMenuState();
}

class _ReleaseNotesMenuState extends State<ReleaseNotesMenu> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

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
                'UPDATE $_version',
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
                        '* ADDED CRUMBLING PLATFORMS & SCREEN SHAKE\n'
                        '* FIXED GAPLESS AUDIO LOOPING BUG ON ANDROID\n'
                        '* UPDATED TO PERFECT BGM PROGRESSION SPEED\n'
                        '* PREVENTED DASHING WHEN FALLING OFF LEDGES\n'
                        '* ADDED WHAT\'S NEW BUTTON & UI SOUNDS\n'
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
                    widget.game.overlays.remove('releaseNotes');
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
