import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/shared/services/auth_service.dart';
import 'package:flutter_application/features/holidays/core/holiday_service.dart';
import 'package:flutter_application/features/holidays/widgets/holiday_management_screen.dart';

class MobileHolidaysContent extends StatelessWidget {
  const MobileHolidaysContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final holidayService = HolidayService(authService.dio);
    
    return HolidayManagementScreen(holidayService: holidayService);
  }
}

// [mod:2026-02-24T17:00:00+05:30]
