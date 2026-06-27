import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Backgrounds
  static const Color bgMain  = Color(0xFF060B14);
  static const Color bgGlass = Color(0x960D1627);
  static const Color cardBg  = Color(0xFF0D1627);

  // Brand colours — Apna Saving
  static const Color primary  = Color(0xFF00C896); // Emerald green (savings)
  static const Color accent   = Color(0xFFF59E0B); // Gold (wealth)

  // Semantic
  static const Color success  = Color(0xFF10B981);
  static const Color danger   = Color(0xFFFF4B5C);
  static const Color warning  = Color(0xFFF59E0B); // overdue / pending
  static const Color gold     = Color(0xFFFFD700); // auction winner highlight

  // Text
  static const Color textMuted = Color(0xFF8E9BAE);

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
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
      ),
    ),
    cardTheme: CardTheme(
      color: bgGlass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 54),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 54),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: danger),
      ),
      hintStyle: const TextStyle(color: textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBg,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgMain,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
