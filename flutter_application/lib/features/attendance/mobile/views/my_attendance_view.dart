import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/attendance_service.dart';
import '../../providers/attendance_provider.dart';
import '../widgets/mark_attendance_mobile.dart';
import '../../widgets/attendance_history_tab.dart';
import '../../widgets/attendance_analytics_tab.dart';
import 'package:flutter_application/features/attendance/admin/views/admin_correction_requests.dart';
import '../../widgets/correction_request_form.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/glass_container.dart';

class MobileMyAttendanceContent extends StatefulWidget {
  const MobileMyAttendanceContent({super.key});

  @override
  State<MobileMyAttendanceContent> createState() => _MobileMyAttendanceContentState();
}

class _MobileMyAttendanceContentState extends State<MobileMyAttendanceContent> {
  // Logic has been moved to MarkAttendanceMobile

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : const Color(0xFFF8F9FA),
          child: DefaultTabController(
            length: 2, // Reduced to 2
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Container(
                       margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                       child: Row(
                         children: [
                           Expanded(
                             child: Container(
                               height: 48,
                               padding: const EdgeInsets.all(4),
                               decoration: BoxDecoration(
                                 color: Theme.of(context).brightness == Brightness.dark
                                     ? const Color(0xFF1E293B)
                                     : const Color(0xFFF1F5F9),
                                 borderRadius: BorderRadius.circular(12),
                               ),
                                child: TabBar(
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF334155)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  dividerColor: Colors.transparent,
                                  labelColor: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF818CF8)
                                      : const Color(0xFF4338CA),
                                  unselectedLabelColor: Colors.grey[600],
                                  labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                  tabs: const [
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.touch_app_outlined, size: 16),
                                          SizedBox(width: 4),
                                          Flexible(child: Text("Attendance", overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.history, size: 16),
                                          SizedBox(width: 4),
                                          Flexible(child: Text("My Attendance", overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                             ),
                            ),
                         ],
                       ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  // Tab 1: Mark Attendance
                  const MarkAttendanceMobile(),

                  // Tab 2: My Attendance (Sub-tabs: History / Analytics)
                  _MyAttendanceReportsTab(),
                ],
              ),
            ),
        ),
      );
    },
  );
}
}

class _MyAttendanceReportsTab extends StatefulWidget {
  @override
  State<_MyAttendanceReportsTab> createState() => _MyAttendanceReportsTabState();
}

class _MyAttendanceReportsTabState extends State<_MyAttendanceReportsTab> {
  int _selectedIndex = 0; // 0: History, 1: Analytics, 2: Corrections

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Sub-tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSubTab('History', 0, Icons.history),
                  const SizedBox(width: 24),
                  _buildSubTab('Analytics', 1, Icons.analytics_outlined),
                  const SizedBox(width: 24),
                  _buildSubTab('Corrections', 2, Icons.edit_calendar_outlined),
                ],
              ),
            ),
          ),
          
          
          Expanded(
            child: _selectedIndex == 0 
              ? const AttendanceHistoryTab() 
              : _selectedIndex == 1
                ? const AttendanceAnalyticsTab()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminCorrectionRequests(
                      userId: Provider.of<AuthService>(context, listen: false).user?.employeeId,
                    ),
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildSubTab(String label, int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Standardized Tab Colors
    final selectedColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA);
    final unselectedColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final activeColor = isSelected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: activeColor),
              const SizedBox(width: 8),
              Text(
                label, 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, 
                  fontSize: 12,
                  color: activeColor
                )
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 80,
            color: isSelected ? selectedColor : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
