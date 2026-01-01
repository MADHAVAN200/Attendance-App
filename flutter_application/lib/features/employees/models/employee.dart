class Employee {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String phone;
  final String shift;
  final String avatarUrl;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.phone,
    required this.shift,
    this.avatarUrl = '',
  });
  factory Employee.fromJson(Map<String, dynamic> json) {
    // Determine ID field (id or user_id)
    final id = json['user_id']?.toString() ?? json['id']?.toString() ?? '';
    // Determine Name (user_name or name)
    final name = json['user_name'] ?? json['name'] ?? 'Unknown';
    // Determine Role (designation, designation_title, role)
    final role = json['desg_name'] ?? json['designation_title'] ?? json['role'] ?? 'Employee';
    // Determine Dept
    final dept = json['dept_name'] ?? json['department_title'] ?? json['department'] ?? 'General';
    
    return Employee(
      id: id,
      name: name,
      email: json['email'] ?? '',
      role: role,
      department: dept,
      phone: json['phone'] ?? json['mobile'] ?? '',
      shift: json['shift_name'] ?? json['shift'] ?? 'General',
      avatarUrl: json['avatar'] ?? '',
    );
  }
}
