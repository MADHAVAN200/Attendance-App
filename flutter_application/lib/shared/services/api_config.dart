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
  static const String shifts = '/policies/shifts';

  // Attendance Routes
  static const String timeIn = '/attendance/timein';
  static const String timeOut = '/attendance/timeout';
  static const String myRecords = '/attendance/records';
  static const String adminAttendance = '/attendance/records/admin';
  
  // Holiday Routes
  // Holiday Routes
  static const String holidays = '/holiday';

  // Geofencing Routes
  static const String locations = '/locations'; 
  static const String assignments = '/locations/assignments';
  static const String adminUsers = '/admin/users'; // For fetching users with ?workLocation=true
  static const String nominatimUrl = 'https://nominatim.openstreetmap.org/reverse';
}
