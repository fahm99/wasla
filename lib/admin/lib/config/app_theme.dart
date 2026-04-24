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
  static const Color orange = Color(0xFFFF9800);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryDarkBlue,
        onPrimary: white,
        secondary: yellowAccent,
        onSecondary: primaryDarkBlue,
        surface: white,
        onSurface: primaryDarkBlue,
        error: redDanger,
        onError: white,
      ),
      scaffoldBackgroundColor: lightGrayBg,
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: primaryDarkBlue,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: primaryDarkBlue,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: primaryDarkBlue,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: primaryDarkBlue,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryDarkBlue,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryDarkBlue,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryDarkBlue,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryDarkBlue,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryDarkBlue,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: primaryDarkBlue,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: primaryDarkBlue,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: darkGrayText,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: primaryDarkBlue,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: primaryDarkBlue,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: darkGrayText,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        iconTheme: IconThemeData(color: white),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: white,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkBlue,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          side: const BorderSide(color: primaryDarkBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryDarkBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: redDanger),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.cairo(
          color: darkGrayText,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.cairo(
          color: primaryDarkBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryDarkBlue,
        unselectedItemColor: darkGrayText,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
        ),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellowAccent,
        foregroundColor: primaryDarkBlue,
      ),
      dividerTheme: const DividerThemeData(
        color: mediumGray,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightGrayBg,
        labelStyle: GoogleFonts.cairo(
          color: primaryDarkBlue,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryDarkBlue,
        unselectedLabelColor: darkGrayText,
        indicatorColor: primaryDarkBlue,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
        ),
      ),
    );
  }
}
