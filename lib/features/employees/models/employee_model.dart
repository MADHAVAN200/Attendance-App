class Employee {
  final int userId;
  final String userName;
  final String email;
  final String? phoneNo;
  final String userType;
  final String? designation;
  final int? designationId;
  final String? department;
  final int? departmentId;
  final String? shift;
  final int? shiftId;

  final String? profileImage;

  Employee({
    required this.userId,
    required this.userName,
    required this.email,
    this.phoneNo,
    required this.userType,
    this.designation,
    this.designationId,
    this.department,
    this.departmentId,
    this.shift,
    this.shiftId,
    this.profileImage,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      userId: json['user_id'],
      userName: json['user_name'],
      email: json['email'],
      phoneNo: json['phone_no'],
      userType: json['user_type'],
      designation: json['desg_name'],
      designationId: json['desg_id'],
      department: json['dept_name'],
      departmentId: json['dept_id'],
      shift: json['shift_name'],
      shiftId: json['shift_id'],
      profileImage: json['profile_image'] ?? json['profile_image_url'] ?? json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'email': email,
      'phone_no': phoneNo,
      'user_type': userType,
      'desg_id': designationId,
      'dept_id': departmentId,
      'shift_id': shiftId,
      'profile_image': profileImage,
    };
  }
}

// Simple models for Dropdowns
class Department {
  final int id;
  final String name;
  Department({required this.id, required this.name});
  factory Department.fromJson(Map<String, dynamic> json) => 
      Department(id: json['dept_id'], name: json['dept_name']);
}

class Designation {
  final int id;
  final String name;
  Designation({required this.id, required this.name});
  factory Designation.fromJson(Map<String, dynamic> json) => 
      Designation(id: json['desg_id'], name: json['desg_name']);
}

class Shift {
  final int id;
  final String name;
  Shift({required this.id, required this.name});
  factory Shift.fromJson(Map<String, dynamic> json) => 
      Shift(id: json['shift_id'], name: json['shift_name']);
}
