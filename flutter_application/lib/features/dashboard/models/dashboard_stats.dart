import 'package:flutter/material.dart';

class DashboardStat {
  final String title;
  final String value;
  final String total;
  final String percentageChange;
  final bool isPositiveChange;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  DashboardStat({
    required this.title,
    required this.value,
    this.total = '',
    required this.percentageChange,
    required this.isPositiveChange,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class ActivityItem {
  final String name;
  final String role;
  final String status; // "Clocked In", "Late Check-In", "Sick Leave"
  final String time;
  final String avatarUrl;

  ActivityItem({
    required this.name,
    required this.role,
    required this.status,
    required this.time,
    this.avatarUrl = '',
  });
}

class AnomalyItem {
  final String message;
  final bool isHighPriority;

  AnomalyItem({
    required this.message,
    this.isHighPriority = false,
  });
}
