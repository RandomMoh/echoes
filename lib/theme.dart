import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoesTheme {
  // Stitch Design Taste Palette
  static const Color background = Color(0xFF18181B); // Charcoal Ink
  static const Color surface = Color(0xFFFFFFFF); // Pure Surface
  static const Color mutedSteel = Color(0xFF71717A); // Muted Steel
  static const Color whisperBorder = Color(0x80E2E8F0); // 50% opacity
  static const Color accent = Color(0xFFFFFFFF); // High-contrast White for purely monochrome aesthetic

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: surface,
      textTheme: GoogleFonts.pressStart2pTextTheme().apply(
        bodyColor: surface,
        displayColor: surface,
      ),
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: background,
        onSurface: surface,
      ),
    );
  }
}
