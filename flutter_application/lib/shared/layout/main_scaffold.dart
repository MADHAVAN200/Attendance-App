import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/responsive_builder.dart';
import '../controllers/navigation_controller.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/employees/screens/employees_screen.dart';
import '../../features/live_attendance/live_attendance_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/holidays/screens/holidays_screen.dart';
import '../../features/policy_engine/screens/policy_engine_screen.dart';
import 'package:attendance_app/features/geo_fencing/screens/geo_fencing_screen.dart';
import 'package:attendance_app/features/my_attendance/my_attendance_screen.dart';
import 'package:attendance_app/features/profile/screens/profile_screen.dart';

class MainScaffold extends StatelessWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationController()..setIndex(initialIndex),
      child: const _MainScaffoldContent(),
    );
  }
}

class _MainScaffoldContent extends StatelessWidget {
  const _MainScaffoldContent();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    return _buildContent(nav.selectedIndex);
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const LiveAttendanceScreen();
      case 2:
        return const MyAttendanceScreen();
      case 3:
        return const Padding(
           padding: EdgeInsets.all(24.0),
           child: EmployeesScreen(),
        );
      case 4:
        return const ReportsScreen();
      case 5:
        return const HolidaysScreen();
      case 6:
        return const PolicyEngineScreen();
      case 7:
        return const GeoFencingScreen();
      case 8:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}
