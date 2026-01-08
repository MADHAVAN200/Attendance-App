import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart'; // Import CustomAppBar
import '../../../../shared/navigation/navigation_controller.dart';
import 'dashboard_view.dart';
import '../../../employees/tablet/views/employees_view.dart';
import '../../../employees/mobile/views/employees_mobile_view.dart';
import '../../../attendance/mobile/views/my_attendance_view.dart';
import '../../../attendance/tablet/views/my_attendance_view.dart';
import '../../../live_attendance/mobile/views/live_attendance_view.dart';
import '../../../live_attendance/tablet/views/live_attendance_view.dart';
import '../../../reports/mobile/views/reports_view.dart';
import '../../../reports/tablet/views/reports_view.dart';
import '../../../holidays/mobile/views/holidays_view.dart';
import '../../../holidays/tablet/views/holidays_view.dart';
import '../../../profile/mobile/views/profile_view.dart';

class MobilePortrait extends StatelessWidget {
  const MobilePortrait({super.key});

  @override
  Widget build(BuildContext context) {
    // Gradient Background (matching TabletPortrait)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF334155)]
              : [const Color(0xFFF1F5F9), const Color(0xFFCBD5E1)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: AppSidebar(
          onLinkTap: () {
            Navigator.pop(context); // Close drawer
          },
        ),
        body: Column( // Use Column to stack Header and Body
          children: [
            // Safe Area for Status Bar
            ValueListenableBuilder<PageType>(
              valueListenable: navigationNotifier,
              builder: (context, currentPage, _) {
                return CustomAppBar(
                  title: currentPage.title,
                  showDrawerButton: true, // Show hamburger
                );
              },
            ),
            
            // Expanded Body Content
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

      case PageType.holidays:
          return const MobileHolidaysContent();

      case PageType.profile:
          return const MobileProfileContent();

      case PageType.policyEngine:
      case PageType.geoFencing:
         return Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.screen_rotation, size: 48, color: Colors.grey[400]),
               const SizedBox(height: 16),
               Text(
                 'Desktop/Tablet Only',
                 style: GoogleFonts.poppins(
                   fontSize: 18,
                   fontWeight: FontWeight.w600,
                   color: isDark ? Colors.white : Colors.black87,
                 ),
               ),
               const SizedBox(height: 8),
               Text(
                 'This feature requires a larger screen.',
                 style: GoogleFonts.poppins(
                   fontSize: 14,
                   color: Colors.grey[500],
                 ),
                 textAlign: TextAlign.center,
               ),
             ],
           ),
         );
         
      default:
        return Center(child: Text('Page: ${page.title}'));
    }
  }
}
