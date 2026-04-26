import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color secondaryAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color darkText = Color(0xFF1F2937);
  static const Color lightBg = Color(0xFFF3F4F6);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFE5E7EB);
  static const Color veryLightGrey = Color(0xFFF9FAFB);
  static const Color darkGrey = Color(0xFF374151);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryAmber,
        surface: white,
        error: dangerRed,
        onPrimary: white,
        onSecondary: darkText,
        onSurface: darkText,
        onSurfaceVariant: greyText,
      ),
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Cairo',
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkText),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkText),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkText),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: darkText),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkText),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkText),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: darkText),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkText),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: darkText),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: darkText),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: white),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: white),
          labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: white),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: primaryBlue, width: 2),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerRed),
        ),
        hintStyle: GoogleFonts.cairo(color: greyText, fontSize: 14),
        labelStyle: GoogleFonts.cairo(color: darkText, fontSize: 14),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: greyText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
