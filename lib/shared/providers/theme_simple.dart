import 'package:flutter/material.dart';

// Global Singleton for Theme State
// Using ValueNotifier allows us to listen to changes without Provider injection in main(),
// enabling Hot Reload to work without a full restart.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void toggleTheme() {
  if (themeNotifier.value == ThemeMode.light) {
    themeNotifier.value = ThemeMode.dark;
  } else if (themeNotifier.value == ThemeMode.dark) {
    themeNotifier.value = ThemeMode.light;
  } else {
    // If currently System, default to Light as the first manual override
    // Or we could try to be smarter, but usually users toggle because they want the *other* one.
    // Without context, we can't know what " System" currently is.
    // Let's assume standard toggle behavior: System -> Light (Explicit) -> Dark -> Light...
    themeNotifier.value = ThemeMode.light;
  }
}
