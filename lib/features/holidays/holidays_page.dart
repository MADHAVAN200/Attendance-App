import 'package:flutter/material.dart';
import 'package:flutter_application/features/holidays/views/holidays_mobile_portrait_view.dart';
import 'package:flutter_application/features/holidays/views/holidays_tablet_portrait_view.dart';

class HolidaysPage extends StatelessWidget {
  const HolidaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileHolidaysContent();
        }
        return const HolidaysView();
      },
    );
  }
}

// [upd:2026-04-24T14:00:00+05:30]
