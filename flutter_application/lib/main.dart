import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'shared/providers/theme_simple.dart';
import 'shared/widgets/orientation_guard.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Admin Dashboard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5B60F6),
              primary: const Color(0xFF5B60F6),
              background: const Color(0xFFF8FAFC),
              surface: const Color(0xFFFFFFFF),
              onSurface: const Color(0xFF0F172A),
              secondary: const Color(0xFF64748B),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: GoogleFonts.poppins().fontFamily,
            brightness: Brightness.light,
            cardColor: const Color(0xFFFFFFFF),
            dividerColor: const Color(0xFFE2E8F0),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
              bodyColor: const Color(0xFF0F172A),
              displayColor: const Color(0xFF0F172A),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5B60F6),
              primary: const Color(0xFF5B60F6),
              background: const Color(0xFF0B1220),
              surface: const Color(0xFF1E293B), // Base for glass, handled in widget mostly
              onSurface: const Color(0xFFE5E7EB),
              secondary: const Color(0xFF94A3B8),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0B1220),
            fontFamily: GoogleFonts.poppins().fontFamily,
            brightness: Brightness.dark,
            cardColor: const Color(0xFF1E293B), 
            dividerColor: const Color(0xFF334155),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
              bodyColor: const Color(0xFFE5E7EB),
              displayColor: const Color(0xFFE5E7EB),
            ),
          ),
          themeMode: currentMode,
          // Wrap DashboardScreen with OrientationGuard
          home: const OrientationGuard(child: DashboardScreen()), 
        );
      },
    );
  }
}
