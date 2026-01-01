import 'package:flutter/material.dart';

// Global Singleton for Theme State
// Using ValueNotifier allows us to listen to changes without Provider injection in main(),
// enabling Hot Reload to work without a full restart.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void toggleTheme() {
  if (themeNotifier.value == ThemeMode.light) {
    themeNotifier.value = ThemeMode.dark;
  } else {
    themeNotifier.value = ThemeMode.light;
  }
}
