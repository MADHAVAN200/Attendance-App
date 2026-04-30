import 'package:flutter/material.dart';
import 'package:flutter_application/features/live_attendance/views/live_attendance_mobile_portrait_view.dart';
import 'package:flutter_application/features/live_attendance/views/live_attendance_tablet_portrait_view.dart';

class LiveAttendancePage extends StatelessWidget {
  const LiveAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileLiveAttendanceContent();
        }
        return const LiveAttendanceView();
      },
    );
  }
}

// [mod:2026-02-23T09:00:00+05:30]

// [upd:2026-04-30T14:00:00+05:30]
