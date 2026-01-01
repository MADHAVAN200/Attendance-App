import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    this.desktop,
  });

  static const double mobileLimit = 650;
  static const double tabletLimit = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileLimit;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileLimit &&
      MediaQuery.of(context).size.width < tabletLimit;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletLimit;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= tabletLimit) {
      return desktop ?? tablet;
    } else if (width >= mobileLimit) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
