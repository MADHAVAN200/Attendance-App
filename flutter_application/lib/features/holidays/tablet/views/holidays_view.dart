import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/policy_service.dart';
import '../../views/holiday_management_screen.dart';

class HolidaysView extends StatelessWidget {
  const HolidaysView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize PolicyService
    final policyService = PolicyService();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.transparent : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: HolidayManagementScreen(policyService: policyService),
    );
  }
}
