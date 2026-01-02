
import 'package:flutter/material.dart';

class AttendanceRecord {
  final String date;
  final String timeIn;
  final String timeOut;
  final String location;
  final String status;
  final String totalHours;
  final Color statusColor;

  AttendanceRecord({
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.location,
    required this.status,
    required this.totalHours,
    required this.statusColor,
  });

  static List<AttendanceRecord> dummyData = [
    AttendanceRecord(
      date: 'Today, 02 Jan',
      timeIn: '09:30 AM',
      timeOut: '--:--',
      location: 'Office - HQ',
      status: 'Present',
      totalHours: '4h 12m',
      statusColor: const Color(0xFF10B981),
    ),
    AttendanceRecord(
      date: 'Yesterday, 01 Jan',
      timeIn: '09:15 AM',
      timeOut: '06:45 PM',
      location: 'Office - HQ',
      status: 'On Time',
      totalHours: '9h 30m',
      statusColor: const Color(0xFF10B981),
    ),
    AttendanceRecord(
      date: '31 Dec 2025',
      timeIn: '09:45 AM',
      timeOut: '06:15 PM',
      location: 'Remote',
      status: 'Late',
      totalHours: '8h 30m',
      statusColor: const Color(0xFFF59E0B),
    ),
    AttendanceRecord(
      date: '30 Dec 2025',
      timeIn: '--:--',
      timeOut: '--:--',
      location: '-',
      status: 'On Leave',
      totalHours: '0h',
      statusColor: const Color(0xFFEF4444),
    ),
    AttendanceRecord(
      date: '29 Dec 2025',
      timeIn: '09:30 AM',
      timeOut: '06:30 PM',
      location: 'Office - HQ',
      status: 'On Time',
      totalHours: '9h 00m',
      statusColor: const Color(0xFF10B981),
    ),
  ];
}
