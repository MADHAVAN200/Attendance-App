import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/responsive_builder.dart';
import 'live_attendance_controller.dart';
import 'mobile/live_attendance_mobile.dart';
import 'tablet/live_attendance_tablet.dart';

class LiveAttendanceScreen extends StatelessWidget {
  const LiveAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Immersive Mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return ChangeNotifierProvider(
      create: (_) => LiveAttendanceController()..init(),
      child: const ResponsiveBuilder(
        mobile: LiveAttendanceMobile(),
        tablet: LiveAttendanceTablet(),
        desktop: LiveAttendanceTablet(), // Reuse Tablet logic for now or custom desktop
      ),
    );
  }
}
