import 'package:flutter/material.dart';
import 'widgets/stat_card.dart'; // Ensure these widgets are accessible or moved if needed
// Actually, widgets are in ../widgets/ relative to screens/ so from here (root of dashboard) it is widgets/
import 'widgets/quick_action_card.dart';
import 'models/dashboard_stats.dart';

// Activity and Anomaly models seem to be used in widgets but maybe defined there or in models.
// Based on previous file, ActivityItem and AnomalyItem classes were likely in the same file or imported.
// I see imports: activity_list.dart, chart_section.dart. 
// I will check imports of original file.
import 'widgets/activity_list.dart'; // Defines ActivityItem likely
// AnomalyItem is likely in activity_list.dart or chart_section.dart or defined inline in previous file?
// In previous view_file, AnomalyItem was used but no import showed it explicitly unless it's in models/dashboard_stats.dart or one of the widgets.
// Reading imports again:
// import '../widgets/stat_card.dart';
// import '../widgets/chart_section.dart';
// import '../widgets/activity_list.dart';
// import '../widgets/quick_action_card.dart';
// import '../models/dashboard_stats.dart';
//
// AnomalyItem usage: AnomalyItem(message: ...). 
// I'll assume it's available or I will fix imports later. I'll import everything needed.

class DashboardController extends ChangeNotifier {
  
  List<DashboardStat> get stats => [
      DashboardStat(
        title: 'Present Today',
        value: '56',
        total: '80',
        percentageChange: '+2.5%',
        isPositiveChange: true,
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF10B981),
        iconBgColor: const Color(0xFF10B981),
      ),
      DashboardStat(
        title: 'Absent',
        value: '3',
        percentageChange: '-1.2%',
        isPositiveChange: true,
        icon: Icons.cancel_outlined,
        iconColor: const Color(0xFFEF4444),
        iconBgColor: const Color(0xFFEF4444),
      ),
      DashboardStat(
        title: 'Late Check-Ins',
        value: '5',
        percentageChange: '+4%',
        isPositiveChange: false,
        icon: Icons.access_time_filled_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFF59E0B),
      ),
      DashboardStat(
        title: 'On Leave',
        value: '4',
        percentageChange: 'Planned',
        isPositiveChange: true,
        icon: Icons.calendar_today_rounded,
        iconColor: const Color(0xFF6366F1),
        iconBgColor: const Color(0xFF6366F1),
      ),
  ];

  List<Map<String, dynamic>> get quickActions => [
    {
      'title': 'Add Employee',
      'subtitle': 'Create new user profile',
      'icon': Icons.person_add_alt_1_rounded,
      'color': const Color(0xFF4F46E5),
      'onTap': () => debugPrint('Add Employee'),
    },
    {
      'title': 'Generate Report',
      'subtitle': 'Download monthly stats',
      'icon': Icons.description_outlined,
      'color': const Color(0xFF0EA5E9),
      'onTap': () => debugPrint('Generate Report'),
    },
    {
      'title': 'Manage Shifts',
      'subtitle': 'Update work schedules',
      'icon': Icons.calendar_view_week_rounded,
      'color': const Color(0xFF8B5CF6),
      'onTap': () => debugPrint('Manage Shifts'),
    },
  ];

  List<ActivityItem> get activities => [
      ActivityItem(
        name: 'Sarah Wilson',
        role: 'UX Designer',
        status: 'Clocked In',
        time: '08:45 AM',
      ),
      ActivityItem(
        name: 'Mike Johnson',
        role: 'Developer',
        status: 'Late Check-In',
        time: '09:15 AM',
      ),
       ActivityItem(
        name: 'Anna Davis',
        role: 'HR Manager',
        status: 'Sick Leave',
        time: '08:30 AM',
      ),
  ];

  List<AnomalyItem> get anomalies => [
    AnomalyItem(message: 'High absence rate in Sales Dept.', isHighPriority: true),
    AnomalyItem(message: '3 Unapproved Overtime requests.'),
  ];
}
