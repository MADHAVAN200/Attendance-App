import 'package:flutter/material.dart';
import 'views/portrait.dart';
import 'views/landscape.dart';

class DashboardMobile extends StatelessWidget {
  const DashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return const MobileLandscape();
        } else {
          return const MobilePortrait();
        }
      },
    );
  }
}
