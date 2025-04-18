import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimaryColor = Color(0xFF5E35B1); // Deep purple as primary
  static const Color _lightBackgroundColor = Color(0xFFFAF3E0); // Warm white background
  static const Color _lightCardColor = Color(0xFFFFFFFF); // White cards
  static const Color _lightTextColor = Color(0xFF333333); // Dark grey text
  static const Color _lightSecondaryTextColor = Color(0xFF666666); // Medium grey text
  static const Color _lightDividerColor = Color(0xFFE0E0E0); // Light grey dividers
  
  // Dark Theme Colors
  static const Color _darkPrimaryColor = Color(0xFFB39DDB); // Light purple as primary
  static const Color _darkBackgroundColor = Color(0xFF121212); // Deep black background
  static const Color _darkCardColor = Color(0xFF1E1E1E); // Dark grey cards
  static const Color _darkTextColor = Color(0xFFEAEAEA); // Soft white text
  static const Color _darkSecondaryTextColor = Color(0xFFAAAAAA); // Light grey text
  static const Color _darkDividerColor = Color(0xFF2C2C2C); // Dark grey dividers

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    cardColor: _lightCardColor,
    dividerColor: _lightDividerColor,
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightPrimaryColor.withOpacity(0.8),
      surface: _lightCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightTextColor,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _lightTextColor,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _lightTextColor,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _lightTextColor,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _lightTextColor,
      ),
      headlineSmall: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _lightTextColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _lightTextColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _lightTextColor,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _lightSecondaryTextColor,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        color: _lightTextColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        color: _lightTextColor,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        color: _lightSecondaryTextColor,
        height: 1.6,
      ),
    ),
    cardTheme: CardTheme(
      color: _lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _lightPrimaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        side: BorderSide(color: _lightPrimaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightPrimaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade500),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightBackgroundColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _lightTextColor),
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _lightTextColor,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _lightPrimaryColor,
      unselectedItemColor: _lightSecondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _lightCardColor,
      contentTextStyle: GoogleFonts.montserrat(
        color: _lightTextColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    cardColor: _darkCardColor,
    dividerColor: _darkDividerColor,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkPrimaryColor.withOpacity(0.8),
      surface: _darkCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _darkTextColor,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _darkTextColor,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _darkTextColor,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _darkTextColor,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _darkTextColor,
      ),
      headlineSmall: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _darkTextColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkTextColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _darkTextColor,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _darkSecondaryTextColor,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        color: _darkTextColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        color: _darkTextColor,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        color: _darkSecondaryTextColor,
        height: 1.6,
      ),
    ),
    cardTheme: CardTheme(
      color: _darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _darkPrimaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        side: BorderSide(color: _darkPrimaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkCardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkPrimaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade500),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBackgroundColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _darkTextColor),
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _darkTextColor,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkCardColor,
      selectedItemColor: _darkPrimaryColor,
      unselectedItemColor: _darkSecondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkCardColor,
      contentTextStyle: GoogleFonts.montserrat(
        color: _darkTextColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
