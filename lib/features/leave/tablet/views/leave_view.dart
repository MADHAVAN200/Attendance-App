import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../mobile/views/leave_mobile_view.dart';
import 'leave_tablet_portrait.dart';
import 'leave_tablet_landscape.dart';

class LeaveView extends StatelessWidget {
  const LeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => const LeaveMobileView(),
      tablet: (BuildContext context) => OrientationLayoutBuilder(
        portrait: (context) => const LeaveTabletPortrait(),
        landscape: (context) => const LeaveTabletLandscape(),
      ),
      desktop: (BuildContext context) => const LeaveTabletLandscape(), // Use Master-Detail for desktop too
    );
  }
}
