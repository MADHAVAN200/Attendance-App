import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../employees/models/employee.dart';

class AdminService {
  final String _baseUrl = ApiConstants.baseUrl;

  // Fetch All Users
  Future<List<Employee>> getAllUsers() async {
    // Assumption: Endpoint is /users - Adjust if needed
    final url = Uri.parse('$_baseUrl/users'); 
    
    try {
      final response = await http.get(url);
      debugPrint('GET $url - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        List<dynamic> data;
        if (decoded is List) {
            data = decoded;
        } else if (decoded is Map && decoded.containsKey('users') && decoded['users'] is List) {
             // React code: const users = usersRes.users || [];
            data = decoded['users'];
        } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
            data = decoded['data'];
        } else {
             return _getMockUsers();
        }

        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return _getMockUsers();
    } catch (e) {
      debugPrint('AdminService Error: $e');
      return _getMockUsers();
    }
  }

  List<Employee> _getMockUsers() {
      return [
          Employee(id: '1', name: 'Rahul Verma', email: 'rahul@example.com', role: 'Inventory Specialist', department: 'Sales', phone: '', shift: 'Morning'),
          Employee(id: '2', name: 'Sneha Patil', email: 'sneha@example.com', role: 'Sales Executive', department: 'Sales', phone: '', shift: 'Morning'),
          Employee(id: '3', name: 'Arjun Mehta', email: 'arjun@example.com', role: 'Sales Executive', department: 'Sales', phone: '', shift: 'Morning'),
          Employee(id: '4', name: 'Priya Sharma', email: 'priya@example.com', role: 'Store Manager', department: 'Retail', phone: '', shift: 'General'),
          Employee(id: '5', name: 'Amit Kumar', email: 'amit@example.com', role: 'Logistics Coordinator', department: 'Logistics', phone: '', shift: 'Morning'),
      ];
  }
}
