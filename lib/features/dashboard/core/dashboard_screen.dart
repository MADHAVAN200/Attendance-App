import 'package:flutter/material.dart';
import 'package:flutter_application/shared/layout/main_layout.dart';
import 'package:flutter_application/features/dashboard/views/dashboard_tablet_portrait_view.dart';
import 'package:flutter_application/features/dashboard/widgets/dashboard_mobile_landscape_view.dart';
import 'package:flutter_application/features/dashboard/widgets/dashboard_mobile_portrait_switcher.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile Breakpoint (Content Width < 600 typically means Portrait Phone)
        // Check for Mobile Landscape: Landscape implementation on Width < 900?
        if (constraints.maxWidth < 600) {
           return const MobilePortrait();
        }

        return OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return const TabletPortrait();
            } else {
              // LANDSCAPE
              // If width is smaller than typical Tablet Landscape (1024+), use Mobile Landscape
              // Using 900 as breakpoint.
              if (constraints.maxWidth < 900) {
                return const MobileLandscape();
              }
              return const MainLayout(); // Tablet/Desktop Landscape
            }
          },
        );
      },
    );
  }
}

// [mod:2026-02-22T09:30:00+05:30]
