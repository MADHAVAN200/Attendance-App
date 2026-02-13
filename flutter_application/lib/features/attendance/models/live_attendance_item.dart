import '../../../../features/employees/models/employee_model.dart';
import 'attendance_record.dart';

class LiveAttendanceItem {
  final Employee user;
  final List<AttendanceRecord>? _records; // Make internal storage nullable
  
  // Fail-safe getter: absolutely guaranteed to return a List (never Null)
  List<AttendanceRecord> get records => _records ?? [];
  
  // Computed Properties
  String get name => user.userName; 
  String get designation => user.designation ?? 'N/A';
  String get department => user.department ?? 'General';
  
  AttendanceRecord? get latestRecord {
    final list = records;
    if (list.isEmpty) return null;
    return list.last;
  }

  String get status {
    final record = latestRecord;
    if (record == null) return "Absent";
    if (record.timeOut == null) return "Active"; // Currently clocked in
    return "Present"; // Clocked out
  }

  bool get isLate {
    final record = latestRecord;
    return record != null && record.lateMinutes > 0;
  }
  
  // Helper to get display color based on status
  String get statusLabel {
    final currentStatus = status;
    if (currentStatus == "Active" && isLate) return "Late Active";
    if (currentStatus == "Present" && isLate) return "Late";
    return currentStatus;
  }

  // Constructor with defensive check
  LiveAttendanceItem({
    required this.user, 
    List<AttendanceRecord>? records
  }) : _records = records ?? [];
}
