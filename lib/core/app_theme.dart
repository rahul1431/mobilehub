import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgMain = Color(0xFF060B14);
  static const Color bgGlass = Color(0x960D1627);
  static const Color primary = Color(0xFF00C6FF);
  static const Color accent = Color(0xFFA855F7);
  static const Color textMuted = Color(0xFF8E9BAE);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFFF4B5C);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgMain,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: bgGlass,
      background: bgMain,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14),
      ),
    ),
    cardTheme: CardTheme(
      color: bgGlass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
  );
}
