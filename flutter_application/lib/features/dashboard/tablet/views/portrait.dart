import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/dashboard_provider.dart';
import '../../../../shared/models/dashboard_model.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/navigation/navigation_controller.dart';
import '../../dashboard.dart';
import '../widgets/action_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/anomalies_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/trends_chart.dart';
import 'dashboard_view.dart';
import '../../../employees/tablet/views/employees_view.dart';
import '../../../attendance/tablet/views/my_attendance_view.dart';
import '../../../live_attendance/tablet/views/live_attendance_view.dart';
import '../../../reports/tablet/views/reports_view.dart';
import '../../../leave/tablet/views/leave_view.dart'; // UPDATED
import '../../../policy_engine/tablet/views/policy_engine_view.dart';
import '../../../profile/tablet/views/profile_view.dart';

class TabletPortrait extends StatelessWidget {
  const TabletPortrait({super.key});

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
        extendBodyBehindAppBar: true, 
        backgroundColor: Colors.transparent, // Transparent to show gradient
        drawer: AppSidebar(
          onLinkTap: () {
            Navigator.pop(context); // Close drawer on selection
          },
        ),
        body: Stack(
          children: [
            // Background Elements could go here
            
            Column(
              children: [
                // Sticky Header
                ValueListenableBuilder<PageType>(
                  valueListenable: navigationNotifier,
                  builder: (context, currentPage, _) {
                    return CustomAppBar(
                      title: currentPage.title,
                      showDrawerButton: true,
                    );
                  }
                ),

                // Scrollable Content Region
                Expanded(
                  child: ValueListenableBuilder<PageType>(
                    valueListenable: navigationNotifier,
                    builder: (context, currentPage, _) {
                      // Dynamic Body Content
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
                           return LeaveView(); // UPDATED (removed const)
                        case PageType.policyEngine:
                           return const PolicyEngineView();
                        case PageType.geoFencing:
                           return Center(
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.screen_rotation, size: 64, color: Colors.grey[400]),
                                 const SizedBox(height: 24),
                                 Text(
                                   'Please rotate your device',
                                   style: GoogleFonts.poppins(
                                     fontSize: 20,
                                     fontWeight: FontWeight.w600,
                                     color: isDark ? Colors.white : Colors.black87,
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   'Geo-Fencing features require landscape mode',
                                   style: GoogleFonts.poppins(
                                     fontSize: 14,
                                     color: Colors.grey[500],
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                               ],
                             ),
                           );
                        case PageType.profile:
                           return const ProfileView();
                        default:
                          return Center(child: Text('Page: ${currentPage.title}'));
                      }
                    }
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(PageType page) {
    switch (page) {
      case PageType.dashboard:
        return const DashboardView();
      case PageType.employees:
        return const EmployeesView();
      default:
        return Center(child: Text('Coming Soon: ${page.title}'));
    }
  }
}


