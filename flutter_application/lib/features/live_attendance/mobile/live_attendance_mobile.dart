import 'package:flutter/material.dart';
import 'views/portrait.dart';
import 'views/landscape.dart';

class LiveAttendanceMobile extends StatelessWidget {
  const LiveAttendanceMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? const MobilePortrait()
            : const MobileLandscape();
      },
    );
  }
}
