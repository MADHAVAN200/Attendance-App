import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/shared/services/auth_service.dart';
import 'package:flutter_application/features/holidays/core/holiday_service.dart';
import 'package:flutter_application/features/holidays/widgets/holiday_management_screen.dart';

class HolidaysView extends StatelessWidget {
  const HolidaysView({super.key});

  @override
  Widget build(BuildContext context) {
    // This view is used by MainLayout (Tablet/Desktop)
    final authService = Provider.of<AuthService>(context, listen: false);
    final holidayService = HolidayService(authService.dio);
    
    return HolidayManagementScreen(holidayService: holidayService);
  }
}

// [upd:2026-04-24T09:00:00+05:30]
