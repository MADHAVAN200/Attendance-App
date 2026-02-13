import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/sidebars/sidebar_mobile.dart';
import '../../../../shared/widgets/custom_app_bar.dart'; // Import CustomAppBar
import '../../../../shared/navigation/navigation_controller.dart';
import 'dashboard_view.dart';
import '../../../employees/mobile/views/employees_mobile_view.dart';
import '../../../attendance/mobile/views/my_attendance_view.dart';
import '../../../live_attendance/mobile/views/live_attendance_view.dart';
import '../../../reports/mobile/views/reports_view.dart';
import '../../../profile/mobile/views/profile_view.dart';
import '../../../geo_fencing/mobile/views/geo_fencing_view.dart';
import '../../../policy_engine/tablet/views/policy_engine_view.dart';
import '../../../leave/tablet/views/leave_view.dart';

import '../../../feedback/mobile/views/feedback_mobile_view.dart';

class MobilePortrait extends StatelessWidget {
  const MobilePortrait({super.key});

  @override
  Widget build(BuildContext context) {
    // Gradient Background (matching TabletPortrait)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Container(
        color: isDark ? const Color(0xFF101828) : const Color(0xFFF1F5F9), 
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: SidebarMobile(
            onLinkTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          body: Column(
            children: [
              // appBar now correctly handles its own SafeArea background
              ValueListenableBuilder<PageType>(
                valueListenable: navigationNotifier,
                builder: (context, currentPage, _) {
                  return CustomAppBar(
                    title: currentPage.title,
                    showDrawerButton: true,
                  );
                },
              ),
              
              Expanded(
                child: ValueListenableBuilder<PageType>(
                  valueListenable: navigationNotifier,
                  builder: (context, currentPage, child) {
                    return _buildContent(context, currentPage, isDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PageType page, bool isDark) {
    switch (page) {
      case PageType.dashboard:
        return const MobileDashboardContent();
      
      // Reusing Tablet Views where compatible or placeholders
      case PageType.employees:
         return const EmployeesMobileView();
      
      case PageType.myAttendance:
         return const MobileMyAttendanceContent();
      
      case PageType.liveAttendance:
          return const MobileLiveAttendanceContent();

      case PageType.reports:
          return const MobileReportsContent();

      case PageType.leavesAndHolidays: // UPDATED
          return LeaveView();

      case PageType.profile:
          return const MobileProfileContent();

      case PageType.policyEngine:
         return const PolicyEngineView();

      case PageType.geoFencing:
        return const MobileGeoFencingContent();



      // PageType.leaves case REMOVED (merged above)

      case PageType.feedback:
        return const FeedbackMobileView();
      
      default:
        return const SizedBox.shrink();
    }
  }
}
