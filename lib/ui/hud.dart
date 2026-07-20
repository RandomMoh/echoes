import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../game/echoes_game.dart';
import 'package:google_fonts/google_fonts.dart';

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

          // Settings and Pause Buttons
          Positioned(
            top: 24,
            right: 24,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    game.pauseEngine();
                    game.overlays.add('settings');
                    game.overlays.remove('hud');
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: EchoesTheme.background.withValues(alpha: 0.5),
                      border: Border.all(color: EchoesTheme.whisperBorder, width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: EchoesTheme.surface,
                      size: 20,
                    ),
                  ),
                ),
                GestureDetector(
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
              ],
            ),
          ).animate().fadeIn(delay: 700.ms, duration: 800.ms),

          // Health Bar
          Positioned(
            top: 24,
            left: 24,
            child: ValueListenableBuilder<int>(
              valueListenable: game.livesNotifier,
              builder: (context, lives, child) {
                return Row(
                  children: List.generate(5, (index) {
                    final filled = index < lives;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: PixelHeart(filled: filled)
                          .animate(target: filled ? 0 : 1)
                          .shakeX(hz: 8, amount: 3, duration: 400.ms, curve: Curves.easeInOut)
                          .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 200.ms)
                          .then()
                          .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 200.ms),
                    );
                  }),
                );
              },
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

          // Score Display
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: game.scoreNotifier,
                      builder: (context, score, child) {
                        return Text(
                          '${score.toString().padLeft(6, '0')}',
                          style: GoogleFonts.vt323(
                            color: Colors.white,
                            fontSize: 32,
                            height: 1.0,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: game.highScoreNotifier,
                      builder: (context, highScore, child) {
                        return Text(
                          'HI ${highScore.toString().padLeft(6, '0')}',
                          style: GoogleFonts.vt323(
                            color: Colors.amberAccent,
                            fontSize: 20,
                            height: 1.0,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPointerDown,
    required VoidCallback onPointerUp,
  }) {
    return ValueListenableBuilder<String>(
      valueListenable: game.buttonSizeNotifier,
      builder: (context, sizeType, child) {
        return ValueListenableBuilder<String>(
          valueListenable: game.buttonStyleNotifier,
          builder: (context, styleType, child) {
            
            double size = sizeType == 'Small' ? 60.0 : 100.0;
            double iconSize = sizeType == 'Small' ? 32.0 : 48.0;
            
            BoxDecoration decoration;
            if (styleType == 'Circular') {
              decoration = BoxDecoration(
                color: EchoesTheme.background.withValues(alpha: 0.8),
                border: Border.all(color: EchoesTheme.whisperBorder, width: 2),
                shape: BoxShape.circle,
              );
            } else if (styleType == 'Rounded') {
              decoration = BoxDecoration(
                color: EchoesTheme.background.withValues(alpha: 0.8),
                border: Border.all(color: EchoesTheme.whisperBorder, width: 2),
                borderRadius: BorderRadius.circular(16),
              );
            } else { // Square
              decoration = BoxDecoration(
                color: EchoesTheme.background.withValues(alpha: 0.8),
                border: Border.all(color: EchoesTheme.whisperBorder, width: 2),
                borderRadius: BorderRadius.zero,
              );
            }

            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => onPointerDown(),
              onPointerUp: (_) => onPointerUp(),
              onPointerCancel: (_) => onPointerUp(),
              child: Container(
                width: size,
                height: size,
                decoration: decoration,
                child: Center(
                  child: Icon(icon, color: EchoesTheme.surface, size: iconSize),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PixelHeart extends StatelessWidget {
  final bool filled;
  const PixelHeart({super.key, required this.filled});

  @override
  Widget build(BuildContext context) {
    final color = filled ? Colors.white : Colors.white.withValues(alpha: 0.2);
    return CustomPaint(
      size: const Size(21, 21),
      painter: _HeartPainter(color),
    );
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;
  _HeartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..isAntiAlias = false;
    final w = size.width / 7;
    final h = size.height / 7;

    void drawPixel(int x, int y) {
      canvas.drawRect(Rect.fromLTWH(x * w, y * h, w, h), paint);
    }

    final pixels = [
      [1,0], [2,0], [4,0], [5,0],
      [0,1], [1,1], [2,1], [3,1], [4,1], [5,1], [6,1],
      [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2],
      [0,3], [1,3], [2,3], [3,3], [4,3], [5,3], [6,3],
      [1,4], [2,4], [3,4], [4,4], [5,4],
      [2,5], [3,5], [4,5],
      [3,6],
    ];

    for (var p in pixels) {
      drawPixel(p[0], p[1]);
    }
  }

  @override
  bool shouldRepaint(_HeartPainter old) => color != old.color;
}
