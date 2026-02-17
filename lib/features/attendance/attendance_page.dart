import 'package:flutter/material.dart';
import 'package:flutter_application/features/attendance/views/attendance_mobile_portrait_view.dart';
import 'package:flutter_application/features/attendance/views/attendance_tablet_portrait_view.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileMyAttendanceContent();
        }
        return const MyAttendanceView();
      },
    );
  }
}

// [mod:2026-02-17T09:00:00+05:30]
