import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/responsive_builder.dart';
import 'attendance_controller.dart';
import 'mobile/attendance_mobile.dart';
import 'tablet/attendance_tablet.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Enable immersive mode (hide status and nav bars)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Restore system UI overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceController(),
      child: const Scaffold(
        body: ResponsiveBuilder(
          mobile: AttendanceMobile(),
          tablet: AttendanceTablet(),
        ),
      ),
    );
  }
}
