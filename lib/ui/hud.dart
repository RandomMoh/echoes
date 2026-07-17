import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../game/echoes_game.dart';

class GameHUD extends StatelessWidget {
  final EchoesGame game;

  const GameHUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Left/Right Controls
          Positioned(
            left: 32,
            bottom: 32,
            child: Row(
              children: [
                _buildControlButton(
                  icon: Icons.keyboard_arrow_left,
                  onPointerDown: () => game.movePlayerLeft(),
                  onPointerUp: () => game.stopPlayer(),
                ),
                const SizedBox(width: 40),
                _buildControlButton(
                  icon: Icons.keyboard_arrow_right,
                  onPointerDown: () => game.movePlayerRight(),
                  onPointerUp: () => game.stopPlayer(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

          // Jump Control
          Positioned(
            right: 32,
            bottom: 32,
            child: _buildControlButton(
              icon: Icons.keyboard_double_arrow_up,
              onPointerDown: () => game.jumpPlayer(),
              onPointerUp: () {},
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

          // Pause Button
          Positioned(
            top: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                game.pauseEngine();
                game.overlays.add('pause');
                game.overlays.remove('hud');
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: EchoesTheme.background.withValues(alpha: 0.5),
                  border: Border.all(color: EchoesTheme.whisperBorder, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                child: const Icon(
                  Icons.pause,
                  color: EchoesTheme.surface,
                  size: 20,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 700.ms, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPointerDown,
    required VoidCallback onPointerUp,
  }) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onPointerDown(),
      onPointerUp: (_) => onPointerUp(),
      onPointerCancel: (_) => onPointerUp(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: EchoesTheme.background.withValues(alpha: 0.8),
          border: Border.all(color: EchoesTheme.whisperBorder, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Center(
          child: Icon(icon, color: EchoesTheme.surface, size: 48),
        ),
      ),
    );
  }
}
