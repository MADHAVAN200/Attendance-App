class ApiConfig {
  // Base
  // static const String baseUrl = 'http://172.16.15.118:5001'; 
  
  // Admin User Routes
  static const String users = '/admin/users';
  static const String user = '/admin/user'; // + /:id
  static const String bulkUpload = '/admin/users/bulk';
  static const String bulkValidate = '/admin/users/bulk-validate';
  static const String bulkCreate = '/admin/users/bulk-json';

  // Dropdown Data Routes
  static const String departments = '/admin/departments';
  static const String designations = '/admin/designations';
  static const String shifts = '/admin/shifts';

  // Attendance Routes
  static const String timeIn = '/attendance/timein';
  static const String timeOut = '/attendance/timeout';
  static const String myRecords = '/attendance/records';
  static const String adminAttendance = '/attendance/records/admin';
  
  // Holiday Routes
  static const String holidays = '/holiday';
}
