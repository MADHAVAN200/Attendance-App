import 'package:flutter/material.dart';

class Employee {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String role;
  final String department;
  final String shift;
  final String status;
  final String phone;
  final Color color;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    required this.department,
    required this.shift,
    required this.status,
    required this.phone,
    required this.color,
  });

  static List<Employee> get dummyData => [
    const Employee(
      id: '1',
      name: 'Sarah Wilson',
      email: 'sarah.w@company.com',
      avatar: 'S',
      role: 'UX Designer',
      department: 'Product',
      shift: '09:00 - 17:00',
      status: 'Active',
      phone: '9876543210',
      color: Colors.blue,
    ),
    const Employee(
      id: '2',
      name: 'Mike Johnson',
      email: 'mike.j@company.com',
      avatar: 'M',
      role: 'Senior Dev',
      department: 'Engineering',
      shift: '10:00 - 18:00',
      status: 'On Leave',
      phone: '9876543211',
      color: Colors.orange,
    ),
    const Employee(
      id: '3',
      name: 'Anna Davis',
      email: 'anna.d@company.com',
      avatar: 'A',
      role: 'HR Manager',
      department: 'Human Resources',
      shift: '08:00 - 16:00',
      status: 'Active',
      phone: '9876543212',
      color: Colors.purple,
    ),
    const Employee(
      id: '4',
      name: 'James Wilson',
      email: 'james.w@company.com',
      avatar: 'J',
      role: 'Sales Lead',
      department: 'Sales',
      shift: '09:00 - 17:00',
      status: 'Active',
      phone: '9876543213',
      color: Colors.green,
    ),
    const Employee(
      id: '5',
      name: 'Emily Chen',
      email: 'emily.c@company.com',
      avatar: 'E',
      role: 'Frontend Dev',
      department: 'Engineering',
      shift: '10:00 - 18:00',
      status: 'Onboarding',
      phone: '9876543214',
      color: Colors.pink,
    ),
  ];
}
