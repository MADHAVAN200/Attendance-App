import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientationGuard extends StatelessWidget {
  final Widget child;

  const OrientationGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine if it's a mobile device (tablet rule > 600)
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isMobile = shortestSide < 600;

    if (isMobile) {
      // Lock to Portrait for Mobile
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      // Allow all for Tablet
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return child;
  }
}
