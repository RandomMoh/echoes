import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../game/echoes_game.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsMenu extends StatelessWidget {
  final EchoesGame game;

  const SettingsMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: EchoesTheme.background.withValues(alpha: 0.95),
          border: Border.all(color: EchoesTheme.whisperBorder, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SETTINGS',
              style: GoogleFonts.pressStart2p(
                fontSize: 24,
                color: EchoesTheme.surface,
              ),
            ),
            const SizedBox(height: 32),
            _buildSettingRow(
              'BUTTON SIZE',
              ['Small', 'Big'],
              game.buttonSizeNotifier,
              'button_size',
            ),
            const SizedBox(height: 16),
            _buildSettingRow(
              'BUTTON STYLE',
              ['Square', 'Rounded', 'Circular'],
              game.buttonStyleNotifier,
              'button_style',
            ),
            const SizedBox(height: 32),
            _buildMenuButton('RESUME', () {
              game.overlays.remove('settings');
              game.overlays.add('hud');
              game.resumeEngine();
            }),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSettingRow(
    String label,
    List<String> options,
    ValueNotifier<String> notifier,
    String prefKey,
  ) {
    return ValueListenableBuilder<String>(
      valueListenable: notifier,
      builder: (context, currentValue, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: EchoesTheme.mutedSteel,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                final isSelected = currentValue == option;
                return GestureDetector(
                  onTap: () {
                    notifier.value = option;
                    game.prefs.setString(prefKey, option);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? EchoesTheme.surface
                          : Colors.transparent,
                      border: Border.all(color: EchoesTheme.surface, width: 2),
                    ),
                    child: Text(
                      option.toUpperCase(),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: isSelected
                            ? EchoesTheme.background
                            : EchoesTheme.surface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: EchoesTheme.background,
          border: Border.all(color: EchoesTheme.surface, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: EchoesTheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}
