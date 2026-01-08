import 'package:flutter/material.dart';
import '../../shared/navigation/navigation_controller.dart';

class DashboardLogic {
  // KPI Data
  static final List<Map<String, dynamic>> kpiData = [
    {
      'title': 'Present Today',
      'value': '56',
      'total': '/ 60',
      'percentage': '+2.5%',
      'context': 'vs last week',
      'isPositive': true,
      'icon': Icons.check_circle_outline,
      'color': const Color(0xFF10B981), // Green
    },
    {
      'title': 'Absent',
      'value': '3',
      'total': 'Employees',
      'percentage': '-1.2%',
      'context': 'vs last week',
      'isPositive': true, // Decreasing absent is positive
      'icon': Icons.cancel_outlined,
      'color': const Color(0xFFEF4444), // Red
    },
    {
      'title': 'Late Check-ins',
      'value': '5',
      'total': 'Employees',
      'percentage': '+4%',
      'context': 'vs last week',
      'isPositive': false, // Increasing late is negative
      'icon': Icons.access_time,
      'color': const Color(0xFFF59E0B), // Orange
    },
    {
      'title': 'On Leave',
      'value': '4',
      'total': 'Planned',
      'percentage': 'This week',
      'context': '',
      'isPositive': true,
      'icon': Icons.calendar_today_outlined,
      'color': const Color(0xFF6366F1), // Indigo
    },
  ];

  // Quick Actions
  static final List<Map<String, dynamic>> quickActions = [
    {
      'title': 'Add Employee',
      'subtitle': 'Create new user profile',
      'icon': Icons.person_add_outlined,
      'color': const Color(0xFF6366F1),
      'page': PageType.employees,
    },
    {
      'title': 'Generate Report',
      'subtitle': 'Download monthly stats',
      'icon': Icons.description_outlined,
      'color': const Color(0xFF3B82F6),
      'page': PageType.reports,
    },
    {
      'title': 'Live Monitor',
      'subtitle': 'Real-time attendance',
      'icon': Icons.admin_panel_settings_outlined,
      'color': const Color(0xFFEF4444), // Red
      'page': PageType.liveAttendance,
    },
    {
      'title': 'Manage Shifts',
      'subtitle': 'Update work schedules',
      'icon': Icons.work_outline,
      'color': const Color(0xFF8B5CF6),
      'page': PageType.policyEngine,
      'initialTab': 1, // Shift Configuration Tab index
    },
  ];

  // Live Activity Feed
  static final List<Map<String, dynamic>> recentActivity = [
    {
      'name': 'Sarah Wilson',
      'role': 'UX Designer',
      'action': 'Clocked In',
      'time': '08:45 AM',
      'status': 'ontime',
      'avatar': 'S',
      'color': Colors.blue,
    },
    {
      'name': 'Mike Johnson',
      'role': 'Developer',
      'action': 'Late Check-in',
      'time': '09:15 AM',
      'status': 'late',
      'avatar': 'M',
      'color': Colors.orange,
    },
    {
      'name': 'Anna Davis',
      'role': 'HR Manager',
      'action': 'Sick Leave',
      'time': '08:30 AM',
      'status': 'leave',
      'avatar': 'A',
      'color': Colors.purple,
    },
  ];

  // Anomalies
  static final List<String> anomalies = [
    'High absence rate in Sales Dept.',
    '3 Unapproved Overtime requests.',
  ];

  // Chart Data (Mock)
  static final List<double> weeklyPresent = [50, 52, 51, 49, 54, 55, 54];
  static final List<double> weeklyLate = [5, 4, 6, 3, 4, 5, 4];
}
