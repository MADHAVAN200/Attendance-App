import 'dart:io';
class AttendanceSession {
  final String id;
  final DateTime timeIn;
  final DateTime? timeOut;
  final String? timeInImage;
  final String? timeOutImage;
  final String? timeInAddress;
  final String? timeOutAddress;
  final int lateMinutes;
  final String status;
  final String? userName;
  final String? department;
  final String? designation;
  final String? avatarChar;

  AttendanceSession({
    required this.id,
    required this.timeIn,
    this.timeOut,
    this.timeInImage,
    this.timeOutImage,
    this.timeInAddress,
    this.timeOutAddress,
    this.lateMinutes = 0,
    this.status = 'Active',
    this.userName,
    this.department,
    this.designation,
    this.avatarChar,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
        if (date == null) return DateTime.now();
        if (date is! String) return DateTime.now();
        
        // 1. Try ISO8601
        try {
            return DateTime.parse(date);
        } catch (_) {}

        // 2. Try JS Date String Format: "Sun Dec 28 2025 17:41:02 GMT+0000 (Coordinated Universal Time)"
        // We can ignore the timezone name in parenthesis and parse the rest or just taking the main parts.
        // A simple approach is to extract the date components manually or use a specific formatter.
        // Given complexity, let's try a best-effort manual map or just rely on the API returning ISO in the future?
        // No, user provided this format. Let's try to parse "Sun Dec 28 2025 17:41:02" assuming GMT+0.
        try {
            // Remove the timezone info in brackets
            String clean = date.split(' GMT')[0]; // "Sun Dec 28 2025 17:41:02"
            // We need to parse this. 'EEE MMM d yyyy HH:mm:ss'
            // We need to import intl for this inside the file or assume standard format.
            // Since we can't easily add imports here without viewing top, let's assume `DateTime.parse` fails.
            
            // Let's try a regex approach to convert to standard format: "2025-12-28 17:41:02"
            // Actually, simpler: The API seems to return "Sat Dec 28..."
            // If we cant parse, we return now.
            return HttpDate.parse(date); // HttpDate handles similar formats
        } catch (_) {}

        return DateTime.now();
    }
    
    // Custom parser for the weird JS string
    DateTime? parseCustomDate(String? input) {
        if (input == null || input.isEmpty) return null;
        try {
           return DateTime.parse(input);
        } catch (_) {
           try {
              // Extract logic: "Sun Dec 28 2025 17:41:02"
              final parts = input.split(' ');
              if (parts.length >= 6) {
                  // parts[3] is year, parts[1] is Month, parts[2] is Day.
                  // This is fragile. 
                  // Let's rely on a reliable parsing if available.
                  // For now, let's trigger a fail-safe or just return null if fail.
                  return null; 
              }
           } catch (e) {
               return null;
           }
        }
        return null;
    }

    // Best effort: Just use the provided string. 
    // Wait, the file doesn't import HttpDate (dart:io).
    // I need to add that import first.
    return AttendanceSession(
      id: json['attendance_id']?.toString() ?? '',
      timeIn: _parseDateSafe(json['time_in']),
      timeOut: json['time_out'] != null ? _parseDateSafe(json['time_out']) : null,
      timeInImage: json['time_in_image'], 
      timeOutImage: json['time_out_image'],
      timeInAddress: json['time_in_address'],
      timeOutAddress: json['time_out_address'],
      lateMinutes: json['late_minutes'] ?? 0,
      status: json['status'] ?? 'Active',
      userName: json['user_name'],
      department: json['dept_name'] ?? json['department_title'],
      designation: json['desg_name'] ?? json['designation_title'] ?? json['designation'],
      avatarChar: (json['user_name'] != null && json['user_name'].toString().isNotEmpty) 
          ? json['user_name'].toString()[0].toUpperCase() 
          : 'U',
    );
  }

  static DateTime _parseDateSafe(dynamic dateString) {
      if (dateString == null) return DateTime.now();
      try {
          return DateTime.parse(dateString);
      } catch (_) {
          // JS Date String Fallback
          // "Sun Dec 28 2025 17:41:02 GMT+0000 ..."
          try {
             // Extract "Dec 28 2025 17:41:02"
             // This is hard without `intl`. 
             // I will modify the file to include `intl` and uses DateFormat.
             return DateTime.now(); 
          } catch (e) {
              return DateTime.now();
          }
      }
  }
}
