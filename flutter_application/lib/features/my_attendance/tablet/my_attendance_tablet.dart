import 'package:flutter/material.dart';
import 'views/portrait.dart';
import 'views/landscape.dart';

class MyAttendanceTablet extends StatelessWidget {
  const MyAttendanceTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return const TabletLandscape();
        } else {
          return const TabletPortrait();
        }
      },
    );
  }
}
