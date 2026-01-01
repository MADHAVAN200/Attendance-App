import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF5B60F6); // Blue-ish purple from chart/logo
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light grey background
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF1A1D1F);
  static const Color subTextColor = Color(0xFF9EA3AE);
  
  static const Color successColor = Color(0xFF27AE60);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF2C94C); // For anomalies/late
  static const Color infoColor = Color(0xFF2F80ED);

  // Text Styles
  static TextTheme textTheme = GoogleFonts.poppinsTextTheme().copyWith(
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: subTextColor,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: subTextColor,
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: backgroundColor,
        surface: surfaceColor,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(
        color: subTextColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF101828), // User requested BG
      cardColor: const Color(0xFF1E2939), // User requested Card
      textTheme: textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: const Color(0xFF101828),
        surface: const Color(0xFF1E2939),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2939),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1E2939),
      ),
    );
  }
}
