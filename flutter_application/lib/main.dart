import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'shared/layout/main_scaffold.dart';

import 'package:provider/provider.dart';
import 'shared/controllers/theme_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const AttendanceApp(),
    ),
  );
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MANO Dashboard',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const MainScaffold(initialIndex: 0),
          routes: {
            '/live-attendance': (context) => const MainScaffold(initialIndex: 1),
            '/my-attendance': (context) => const MainScaffold(initialIndex: 2),
            '/employees': (context) => const MainScaffold(initialIndex: 3),
            '/reports': (context) => const MainScaffold(initialIndex: 4),
            '/holidays': (context) => const MainScaffold(initialIndex: 5),
            '/policy': (context) => const MainScaffold(initialIndex: 6),
            '/geo-fencing': (context) => const MainScaffold(initialIndex: 7),
            '/profile': (context) => const MainScaffold(initialIndex: 8),
          },
        );
      },
    );
  }
}
