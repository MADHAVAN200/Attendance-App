import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tabletPortrait;
  final Widget? tabletLandscape;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tabletPortrait,
    this.tabletLandscape,
    this.desktop,
  });

  static const int mobileBreakpoint = 600;
  static const int tabletBreakpoint = 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileBreakpoint) {
          return mobile;
        } else if (constraints.maxWidth < tabletBreakpoint) {
          return OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return tabletPortrait ?? mobile;
              }
              return tabletLandscape ?? tabletPortrait ?? mobile;
            },
          );
        } else {
          return desktop ?? tabletLandscape ?? tabletPortrait ?? mobile;
        }
      },
    );
  }
}
