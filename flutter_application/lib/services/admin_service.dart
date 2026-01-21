import 'package:dio/dio.dart';
import 'api_client.dart';

class AdminService {
  final ApiClient _client = ApiClient();

  // --- Users ---
  Future<List<dynamic>> getAllUsers({bool includeWorkLocation = false, String? query}) async {
    try {
      final response = await _client.get('/admin/users', queryParameters: {
        'workLocation': includeWorkLocation,
        if (query != null) 'search': query, // Assuming generic search support
      });
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final response = await _client.get('/admin/user/$userId');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching user detail: $e");
    }
    return null;
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    await _client.post('/admin/user', data: userData);
  }

  Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    await _client.put('/admin/user/$userId', data: userData);
  }

  Future<void> deleteUser(int userId) async {
    await _client.delete('/admin/user/$userId');
  }

  Future<void> bulkDeleteUsers(List<int> userIds) async {
    await Future.wait(userIds.map((id) => deleteUser(id)));
  }

  // --- Bulk Operations ---
  Future<void> bulkUploadExcel(String filePath) async {
    String fileName = filePath.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
    });
    await _client.post('/admin/users/bulk', data: formData);
  }

  Future<Map<String, dynamic>> bulkValidateJson(List<dynamic> users) async {
    final response = await _client.post('/admin/users/bulk-validate', data: {"users": users});
    return response.data;
  }

  Future<void> bulkCreateJson(List<dynamic> users) async {
    await _client.post('/admin/users/bulk-json', data: {"users": users});
  }

  // --- Departments ---
  Future<List<dynamic>> getDepartments() async {
    try {
      final response = await _client.get('/admin/departments');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching departments: $e");
    }
    return [];
  }

  Future<void> createDepartment(String name) async {
    await _client.post('/admin/departments', data: {"dept_name": name});
  }

  // --- Designations ---
  Future<List<dynamic>> getDesignations() async {
    try {
      final response = await _client.get('/admin/designations');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching designations: $e");
    }
    return [];
  }

  Future<void> createDesignation(String name) async {
    await _client.post('/admin/designations', data: {"desg_name": name});
  }

  // --- Shifts (Admin View) ---
  Future<List<dynamic>> getShifts() async {
    try {
      final response = await _client.get('/admin/shifts');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching shifts: $e");
    }
    return [];
  }
}
