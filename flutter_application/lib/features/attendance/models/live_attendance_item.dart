import '../../../../shared/models/employee_model.dart';
import '../../../../shared/models/attendance_model.dart';

class LiveAttendanceItem {
  final Employee user;
  final AttendanceRecord? record;
  
  // Computed Properties
  String get name => user.userName; 
  String get designation => user.designation ?? 'N/A';
  String get department => user.department ?? 'General';
  
  String get status {
    if (record == null) return "Absent";
    if (record!.timeOut == null) return "Active"; // Currently clocked in
    return "Present"; // Clocked out
  }

  bool get isLate => record?.lateMinutes != null && record!.lateMinutes > 0;
  
  // Helper to get display color based on status
  String get statusLabel {
     if (status == "Active" && isLate) return "Late Active";
     if (status == "Present" && isLate) return "Late";
     return status;
  }

  LiveAttendanceItem({required this.user, this.record});
}
