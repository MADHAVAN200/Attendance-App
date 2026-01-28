import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../widgets/mark_attendance_mobile.dart';
import '../widgets/attendance_history_mobile.dart';
import '../widgets/attendance_analytics_mobile.dart';

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
              : const Color(0xFFF8F9FA), // Off-white for light mode
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
              // Main Tab Bar
              Container(
                 margin: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                 height: 40,
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                    labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: "Mark Attendance"),
                      Tab(text: "My Attendance"),
                    ],
                  ),
              ),

              // Tab View
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Mark Attendance (Separated)
                    const MarkAttendanceMobile(),

                    // Tab 2: My Attendance (Sub-tabs: History / Analytics)
                    _MyAttendanceReportsTab(),
                  ],
                ),
              ),
            ],
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
  int _selectedIndex = 0; // 0: History, 1: Analytics

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              _buildSubTab('History', 0, Icons.history),
              const SizedBox(width: 24),
              _buildSubTab('Analytics', 1, Icons.analytics_outlined),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _selectedIndex == 0 
            ? const AttendanceHistoryMobile() 
            : const AttendanceAnalyticsMobile(),
        ),
      ],
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
