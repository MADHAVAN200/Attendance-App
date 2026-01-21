import 'package:dio/dio.dart';
import 'dart:io';
import 'api_client.dart';
import '../shared/models/employee_model.dart';
import '../shared/models/shift_model.dart';

class EmployeeService {
  final ApiClient _client = ApiClient();

  Future<List<Employee>> getEmployees() async {
    try {
      final response = await _client.get('/admin/users');
      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Employee.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching employees: $e");
    }
    return [];
  }

  Future<Employee> getEmployee(int id) async {
    try {
      final response = await _client.get('/admin/user/$id');
      if (response.statusCode == 200 && response.data['ok']) {
        return Employee.fromJson(response.data['data']);
      }
      throw Exception('User not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createEmployee(Map<String, dynamic> data) async {
    await _client.post('/admin/user', data: data);
  }

  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    await _client.put('/admin/user/$id', data: data);
  }

  Future<void> deleteEmployee(int id) async {
    await _client.delete('/admin/user/$id');
  }

  Future<void> bulkDeleteEmployees(List<int> ids) async {
    await Future.wait(ids.map((id) => deleteEmployee(id)));
  }

  Future<Map<String, dynamic>> bulkUploadUsers(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final response = await _client.post('/admin/users/bulk', data: formData);
    return response.data;
  }

  // Dropdowns
  Future<List<Department>> getDepartments() async {
    try {
      final res = await _client.get('/admin/departments');
      if (res.statusCode == 200 && res.data['ok']) {
         return (res.data['data'] as List).map((x) => Department.fromJson(x)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Designation>> getDesignations() async {
    try {
      final res = await _client.get('/admin/designations');
      if (res.statusCode == 200 && res.data['ok']) {
         return (res.data['data'] as List).map((x) => Designation.fromJson(x)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Shift>> getShifts() async {
    try {
      final res = await _client.get('/policies/shifts'); 
      if (res.statusCode == 200 && res.data['ok']) {
         return (res.data['data'] as List).map((x) => Shift.fromJson(x)).toList();
      }
    } catch (_) {}
    return [];
  }
}
