import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientationGuard extends StatefulWidget {
  final Widget child;

  const OrientationGuard({super.key, required this.child});

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard> {
  @override
  void initState() {
    super.initState();
  }

  void _applyOrientation(double shortestSide) {
    // Determine if it's a mobile device (tablet rule > 600)
    final isMobile = shortestSide < 600;

    if (isMobile) {
      // Strictly lock to Portrait for Mobile (Portrait Up Only)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // Allow all orientations for Tablet
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyOrientation(shortestSide);
    });
    return widget.child;
  }
}
