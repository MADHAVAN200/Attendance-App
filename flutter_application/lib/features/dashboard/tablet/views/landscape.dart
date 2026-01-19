import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/navigation/navigation_controller.dart';
import 'dashboard_view.dart';
import '../../../employees/tablet/views/employees_view.dart';
import '../../../attendance/tablet/views/my_attendance_view.dart';
import '../../../live_attendance/tablet/views/live_attendance_view.dart';
import '../../../reports/tablet/views/reports_view.dart';
import '../../../holidays/tablet/views/holidays_view.dart';
import '../../../policy_engine/tablet/views/policy_engine_view.dart';
import '../../../profile/tablet/views/profile_view.dart';
import '../../../leave/views/apply_leave_view.dart';

class TabletLandscape extends StatelessWidget {
  const TabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF334155)]
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            const AppSidebar(), // Sidebar on the left
            Expanded(
              child: Column(
                children: [
                   ValueListenableBuilder<PageType>(
                    valueListenable: navigationNotifier,
                    builder: (context, currentPage, _) {
                      return CustomAppBar(
                        title: currentPage.title,
                        showDrawerButton: false, // No drawer button in landscape (Sidebar visible)
                      );
                    }
                  ),
                  Expanded(
                    child: ValueListenableBuilder<PageType>(
                      valueListenable: navigationNotifier,
                      builder: (context, currentPage, _) {
                        switch (currentPage) {
                          case PageType.dashboard:
                            return const DashboardView();
                          case PageType.employees:
                             return const EmployeesView();
                          case PageType.myAttendance:
                             return const MyAttendanceView();
                          case PageType.liveAttendance:
                             return const LiveAttendanceView();
                          case PageType.reports:
                             return const ReportsView();
                          case PageType.holidays:
                             return const HolidaysView();
                          case PageType.policyEngine:
                             return const PolicyEngineView();
                          case PageType.profile:
                             return const ProfileView();
                          case PageType.applyLeave:
                             return const ApplyLeaveView();
                          case PageType.geoFencing:
                             // GeoFencing might need a specific Tablet View
                             return Center(child: Text('Geo Fencing (Landscape)'));
                          default:
                            return Center(child: Text('Page: ${currentPage.title}'));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
