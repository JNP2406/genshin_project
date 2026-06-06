import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Mode
  static const lightBackground = Color(0xFFF5F0E8);
  static const lightHeader = Color(0xFFE8E0D0);
  static const lightBorder = Color(0xFFC8B89A);

  // Dark Mode
  static const darkBackground = Color(0xFF1E2A3A);
  static const darkHeader = Color(0xFF162030);
  static const darkBorder = Color(0xFFC9A84C);

  // Shared
  static const gold = Color(0xFFEEC249);
  static const navy = Color(0xFF1A1A2E);
  static const cream = Color(0xFFF5F0E8);
  static const blue = Color(0xFF046FE1);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const red = Color(0xFFE53935);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.gold,
    colorScheme: const ColorScheme.light(
      primary: AppColors.gold,
      secondary: AppColors.navy,
      surface: AppColors.lightBackground,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.navy,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.navy,
      ),
      headlineLarge: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.navy,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.navy,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightHeader,
      foregroundColor: AppColors.navy,
      elevation: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightHeader,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.gold,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.cream,
      surface: AppColors.darkBackground,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.cream,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.cream,
      ),
      headlineLarge: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.cream,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Coolvetica',
        color: AppColors.cream,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkHeader,
      foregroundColor: AppColors.cream,
      elevation: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkHeader,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
    ),
  );
}