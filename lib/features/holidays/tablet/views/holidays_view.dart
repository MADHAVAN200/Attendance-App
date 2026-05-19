import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/holiday_service.dart';
import '../../views/holiday_management_screen.dart';

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
