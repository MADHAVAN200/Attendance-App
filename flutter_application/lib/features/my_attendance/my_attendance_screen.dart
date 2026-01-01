import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/responsive_builder.dart';
import 'my_attendance_controller.dart';
import 'mobile/my_attendance_mobile.dart';
import 'tablet/my_attendance_tablet.dart';

class MyAttendanceScreen extends StatelessWidget {
  const MyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAttendanceController(),
      child: const Scaffold(
        body: ResponsiveBuilder(
          mobile: MyAttendanceMobile(),
          tablet: MyAttendanceTablet(),
        ),
      ),
    );
  }
}
