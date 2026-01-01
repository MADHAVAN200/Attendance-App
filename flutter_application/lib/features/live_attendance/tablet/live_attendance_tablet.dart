import 'package:flutter/material.dart';
import 'views/portrait.dart';
import 'views/landscape.dart';

class LiveAttendanceTablet extends StatelessWidget {
  const LiveAttendanceTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? const TabletPortrait()
            : const TabletLandscape();
      },
    );
  }
}
