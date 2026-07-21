import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoesTheme {
  static const Color background = Color(0xFF18181B);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color mutedSteel = Color(0xFF71717A);
  static const Color whisperBorder = Color(0x80E2E8F0);
  static const Color accent = Color(0xFFFFFFFF);

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
