import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // We can't easily access context here to check platform brightness without more boilerplate,
      // but for logic purposes, knowing if we are forcibly dark or light is often enough.
      // However, for the toggle logic, we usually toggle between Light and Dark explicitly.
      return false; // Default assumption or we could check SchedulerBinding.
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
