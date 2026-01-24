import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'package:provider/provider.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/navigation/navigation_controller.dart';
import '../../dashboard.dart';

import 'dashboard_view.dart';
import '../../../employees/tablet/views/employees_view.dart';
import '../../../attendance/tablet/views/my_attendance_view.dart';
import '../../../live_attendance/tablet/views/live_attendance_view.dart';
import '../../../reports/tablet/views/reports_view.dart';
import '../../../leave/tablet/views/leave_view.dart';
import '../../../policy_engine/tablet/views/policy_engine_view.dart';
import '../../../profile/tablet/views/profile_view.dart';
import '../../../feedback/tablet/views/feedback_tablet_view.dart';

class TabletLandscape extends StatelessWidget {
  const TabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF101828) : const Color(0xFFF8FAFC), // Solid background
      // decoration: BoxDecoration(...) removed for flat design
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: ValueListenableBuilder<PageType>(
                  valueListenable: navigationNotifier,
                  builder: (context, currentPage, _) => CustomAppBar(
                    title: currentPage.title,
                    showDrawerButton: false, // Sidebar is visible
                  ),
                ),
                body: ValueListenableBuilder<PageType>(
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
                      case PageType.leavesAndHolidays:
                        return LeaveView();
                      case PageType.policyEngine:
                        return const PolicyEngineView();
                      case PageType.feedback:
                        return const FeedbackTabletView();
                      case PageType.profile:
                        return const ProfileView();
                      default:
                        // GeoFencing check might be needed if mobile-only
                         if (currentPage == PageType.geoFencing) {
                            return const Center(child: Text("Geo-Fencing available in Mobile App"));
                         }
                        return Center(child: Text('Page: ${currentPage.title}'));
                    }
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
