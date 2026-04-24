import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryDarkBlue = Color(0xFF0C1445);
  static const Color yellowAccent = Color(0xFFF9D71C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrayBg = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGrayText = Color(0xFF757575);
  static const Color greenSuccess = Color(0xFF4CAF50);
  static const Color redDanger = Color(0xFFF44336);
  static const Color blueInfo = Color(0xFF2196F3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDarkBlue,
        primary: primaryDarkBlue,
        secondary: yellowAccent,
        surface: white,
        error: redDanger,
      ),
      scaffoldBackgroundColor: lightGrayBg,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        iconTheme: const IconThemeData(color: white),
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: primaryDarkBlue),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: darkGrayText),
        bodySmall: GoogleFonts.cairo(fontSize: 12, color: darkGrayText),
        titleLarge: GoogleFonts.cairo(
            fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkBlue),
        titleMedium: GoogleFonts.cairo(
            fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkBlue),
        titleSmall: GoogleFonts.cairo(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryDarkBlue),
        labelLarge: GoogleFonts.cairo(
            fontSize: 14, fontWeight: FontWeight.bold, color: white),
        labelMedium: GoogleFonts.cairo(
            fontSize: 12, fontWeight: FontWeight.w500, color: darkGrayText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.bold, color: white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: primaryDarkBlue, width: 2),
          textStyle: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryDarkBlue),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          textStyle: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryDarkBlue),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDarkBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: redDanger),
        ),
        hintStyle: GoogleFonts.cairo(fontSize: 14, color: darkGrayText),
        labelStyle: GoogleFonts.cairo(fontSize: 14, color: primaryDarkBlue),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryDarkBlue,
        unselectedItemColor: darkGrayText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellowAccent,
        foregroundColor: primaryDarkBlue,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDarkBlue,
        contentTextStyle: GoogleFonts.cairo(fontSize: 14, color: white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: mediumGray,
        thickness: 1,
      ),
    );
  }
}
