import 'package:flutter/material.dart';
import 'package:flutter_application/features/leave/views/leave_mobile_portrait_view.dart';
import 'package:flutter_application/features/leave/views/leave_tablet_portrait_view.dart';
import 'package:flutter_application/features/leave/views/leave_tablet_landscape_view.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const LeaveMobileView();
        }
        return OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return const LeaveTabletPortrait();
            } else {
              return const LeaveTabletLandscape();
            }
          },
        );
      },
    );
  }
}

// Alias for compatibility
typedef LeaveView = LeavePage;

// [mod:2026-02-20T09:15:00+05:30]

// [upd:2026-04-30T11:30:00+05:30]

// [upd:2026-05-12T17:00:00+05:30]
