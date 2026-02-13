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
    _applyOrientation();
  }

  @override
  void didUpdateWidget(OrientationGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyOrientation();
  }

  void _applyOrientation() {
    // Determine if it's a mobile device (tablet rule > 600)
    // We use WidgetsBinding to ensure MediaQuery is available if needed, 
    // or we can just use a raw check if we don't need context-specific data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final shortestSide = MediaQuery.of(context).size.shortestSide;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
