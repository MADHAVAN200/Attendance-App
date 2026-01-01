import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'services/admin_service.dart';
import '../attendance/services/attendance_service.dart';
import '../attendance/models/attendance_session.dart';
import '../employees/models/employee.dart';

// Models local to this feature or shared?
// CombinedAttendance seems local to the screen logic previously.
class CombinedAttendance {
  final String id;
  final String name;
  final String role;
  final String department;
  final String status;
  final String timeIn;
  final String timeOut;
  final String hours;
  final String location;
  final String avatarChar;

  CombinedAttendance({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.status,
    required this.timeIn,
    this.timeOut = '-',
    this.hours = '-',
    this.location = '-',
    required this.avatarChar,
  });
}

class AttendanceStats {
  final int present;
  final int late;
  final int absent;
  final int active;

  AttendanceStats({
    this.present = 0, 
    this.late = 0, 
    this.absent = 0, 
    this.active = 0
  });
}

// Mock Data for Requests
class CorrectionRequest {
  final int id;
  final String name;
  final String role;
  final String avatarChar;
  final String type;
  final String date;
  final String requestedTime;
  final String systemTime;
  final String reason;
  final String status;
  final List<RequestEvent> timeline;

  CorrectionRequest({
    required this.id, required this.name, required this.role, required this.avatarChar,
    required this.type, required this.date, required this.requestedTime,
    required this.systemTime, required this.reason, required this.status,
    required this.timeline
  });
}

class RequestEvent {
  final String title;
  final String time;
  final String actor;
  RequestEvent(this.title, this.time, this.actor);
}

class LiveAttendanceController extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final AdminService _adminService = AdminService();

  // State
  String _activeTab = 'live'; // 'live', 'requests'
  String _activeView = 'cards'; // 'cards', 'graph'
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<CombinedAttendance> _attendanceData = [];
  AttendanceStats _stats = AttendanceStats();
  
  // Filters
  String _searchTerm = '';
  String _deptFilter = 'All';

  // Requests State
  int _selectedRequestId = 1;
  final List<CorrectionRequest> _requests = [
      CorrectionRequest(
          id: 1, name: 'Rahul Verma', role: 'Inventory Specialist', avatarChar: 'R', 
          type: 'Missed Punch', date: '18 Dec 2023', requestedTime: '09:00 AM', 
          systemTime: '-', reason: 'Forgot to punch in due to urgent delivery handling.', 
          status: 'Pending', 
          timeline: [
              RequestEvent('Request Submitted', '18 Dec, 10:15 AM', 'Rahul Verma'),
              RequestEvent('Under Review', '19 Dec, 09:00 AM', 'System'),
          ]
      ),
      CorrectionRequest(
          id: 2, name: 'Sneha Patil', role: 'Sales Executive', avatarChar: 'S', 
          type: 'Correction', date: '17 Dec 2023', requestedTime: '09:15 AM', 
          systemTime: '10:45 AM', reason: 'Biometric issue, scanner was not working.', 
          status: 'Pending', 
          timeline: [
              RequestEvent('Request Submitted', '17 Dec, 11:30 AM', 'Sneha Patil'),
          ]
      ),
      CorrectionRequest(
          id: 3, name: 'Arjun Mehta', role: 'Sales Executive', avatarChar: 'A', 
          type: 'Overtime', date: '16 Dec 2023', requestedTime: '08:30 PM', 
          systemTime: '06:30 PM', reason: 'Stayed late for year-end inventory audit.', 
          status: 'Approved', 
          timeline: [
              RequestEvent('Request Submitted', '16 Dec, 09:00 PM', 'Arjun Mehta'),
              RequestEvent('Approved', '17 Dec, 10:00 AM', 'Manager'),
          ]
      ),
  ];

  Timer? _refreshTimer;

  // Getters
  String get activeTab => _activeTab;
  String get activeView => _activeView;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  List<CombinedAttendance> get attendanceData => _attendanceData;
  AttendanceStats get stats => _stats;
  String get searchTerm => _searchTerm;
  String get deptFilter => _deptFilter;
  List<CorrectionRequest> get requests => _requests;
  int get selectedRequestId => _selectedRequestId;

  List<CombinedAttendance> get filteredData {
    return _attendanceData.where((item) {
       final matchName = item.name.toLowerCase().contains(_searchTerm.toLowerCase());
       final matchDept = _deptFilter == 'All' || item.department == _deptFilter;
       return matchName && matchDept;
    }).toList();
  }

  void init() {
    _fetchData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) => _fetchData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setActiveView(String view) {
    _activeView = view;
    notifyListeners();
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void setDeptFilter(String dept) {
    _deptFilter = dept;
    notifyListeners();
  }
  
  void setSelectedRequestId(int id) {
    _selectedRequestId = id;
    notifyListeners();
  }

  Future<void> updateDate(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    notifyListeners();
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final results = await Future.wait([
        _adminService.getAllUsers(),
        _attendanceService.getAdminRecords(dateStr),
      ]);

      final users = results[0] as List<Employee>;
      final records = results[1] as List<AttendanceSession>;

      final mappedRecords = records.map((r) {
          return CombinedAttendance(
              id: r.id,
              name: r.userName ?? 'Unknown',
              role: r.designation ?? 'Employee',
              department: r.department ?? 'General',
              status: r.status,
              timeIn: DateFormat('hh:mm a').format(r.timeIn),
              timeOut: r.timeOut != null ? DateFormat('hh:mm a').format(r.timeOut!) : '-',
              hours: r.timeOut != null 
                  ? '${r.timeOut!.difference(r.timeIn).inHours}.${(r.timeOut!.difference(r.timeIn).inMinutes % 60)} hrs' 
                  : '-',
              location: r.timeInAddress ?? '-',
              avatarChar: r.avatarChar ?? 'U',
          );
      }).toList();
      
      int present = records.where((r) => r.timeOut != null).length;
      int active = records.where((r) => r.timeOut == null).length;
      int late = records.where((r) => r.lateMinutes > 0).length;
      int absent = (users.length - records.length).clamp(0, 9999);

      _attendanceData = mappedRecords;
      _stats = AttendanceStats(present: present, late: late, absent: absent, active: active);
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      debugPrint('Error loading live data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
