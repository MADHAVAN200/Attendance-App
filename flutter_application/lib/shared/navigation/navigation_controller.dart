import 'package:flutter/material.dart';

enum PageType {
  dashboard,
  employees,
  myAttendance,
  liveAttendance,
  reports,
  holidays,
  policyEngine,
  geoFencing,
  profile,
  applyLeave,
}

// Map PageType to Title
extension PageTypeExtension on PageType {
  String get title {
    switch (this) {
      case PageType.dashboard: return 'Dashboard';
      case PageType.employees: return 'Employees';
      case PageType.myAttendance: return 'My Attendance';
      case PageType.liveAttendance: return 'Live Attendance';
      case PageType.reports: return 'Reports & Exports';
      case PageType.holidays: return 'Holidays';
      case PageType.policyEngine: return 'Shift Management';
      case PageType.geoFencing:
        return 'Geo-Fencing';
      case PageType.profile:
        return 'My Profile';
      case PageType.applyLeave:
        return 'Apply Leave';
    }
  }

  IconData get icon {
    switch (this) {
      case PageType.dashboard: return Icons.dashboard_outlined;
      case PageType.employees: return Icons.people_outline;
      case PageType.myAttendance: return Icons.calendar_today_outlined;
      case PageType.liveAttendance: return Icons.access_time;
      case PageType.reports: return Icons.show_chart;
      case PageType.holidays: return Icons.event_note_outlined;
      case PageType.policyEngine: return Icons.settings_suggest_outlined;
      case PageType.geoFencing:
        return Icons.location_on_outlined;
      case PageType.profile:
        return Icons.person_outline;
      case PageType.applyLeave:
        return Icons.event_available_outlined;
    }
  }
}

// Global Singleton for Navigation State
final navigationNotifier = ValueNotifier<PageType>(PageType.dashboard);

void navigateTo(PageType page) {
  navigationNotifier.value = page;
}
