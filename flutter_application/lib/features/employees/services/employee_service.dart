import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../shared/services/api_config.dart';
import '../models/employee_model.dart';
import '../../../../shared/services/auth_service.dart';

class EmployeeService {
  final AuthService _authService;
  
  // Use a getter to access the authenticated Dio instance from AuthService
  // Note: Since _dio is private in AuthService, we might need to expose it 
  // OR strictly use a new Dio instance with the same interceptors.
  // Ideally, AuthService should expose a way to make authenticated requests or expose the Dio client.
  // For now, assuming we can get the auth token via AuthService public methods 
  // or we need to refactor AuthService to be more reusable.
  
  // OPTION 1: Pass Dio instance (Recommended if refactoring)
  // OPTION 2: Use AuthService's singleton nature if applicable
  // For this implementation, I will assume we can ask AuthService for the token or reuse its logic.
  // HOWEVER, looking at AuthService, it has a private _dio.
  // The simplest integration without major refactoring is to duplicate the basic Dio setup 
  // or ask user to expose _dio. 
  // Let's rely on passing the Dio instance or Token. 
  
  // BETTER APPROACH: Add a method in AuthService to getting the Dio client, 
  // or just make a new Dio client here and get the token from storage/AuthService.
  
  final Dio _dio;

  EmployeeService(this._authService) : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.users.replaceAll('/admin/users', ''); // Base URL hack or import constant
    // We need the base URL from somewhere. ApiConfig constants are paths.
    // Ideally use ApiConstants.baseUrl from shared/constants
    
    // Add simple interceptor to attach token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
         // This is a temporary simple auth injection. 
         // Integrating tightly with AuthService's lock/refresh logic is better,
         // but requires exposing that logic.
         // For now, assume a valid token is available via AuthService if we expose it,
         // or we'll just implement the methods assuming the caller handles auth headers?
         // No, Service should handle it.
         
         // Let's assume we can get the token.
         // Since providing the full AuthService, let's see if we can get the token.
         // AuthService has `_accessToken` private.
         
         // Fix: We will create a method in this file that assumes it's being configured 
         // with the same Dio instance/Interceptors as AuthService if possible.
         // OR, simpler: Modify AuthService to expose `dio` getter.
         
         return handler.next(options);
      }
    ));
  }

  // ** IMPORTANT FIX ** 
  // Instead of re-implementing auth logic, allow passing the Dio client from AuthService.
  // I will update this constructor to take a Dio instance directly which is already configured.
  
  // 1. Get All Employees
  Future<List<Employee>> getEmployees(Dio dio) async {
    try {
      final response = await dio.get(ApiConfig.users);
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['users'];
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  // 2. Get Single Employee
  Future<Employee> getEmployee(Dio dio, int id) async {
    try {
      final response = await dio.get('${ApiConfig.user}/$id');
      if (response.statusCode == 200 && response.data['success']) {
        return Employee.fromJson(response.data['user']);
      }
      throw Exception('User not found');
    } catch (e) {
      rethrow;
    }
  }

  // 3. Create Employee
  Future<void> createEmployee(Dio dio, Map<String, dynamic> employeeData) async {
    try {
      await dio.post(ApiConfig.user, data: employeeData);
    } catch (e) {
      throw Exception('Failed to create employee: ${e.toString()}');
    }
  }

  // 4. Update Employee
  Future<void> updateEmployee(Dio dio, int id, Map<String, dynamic> updates) async {
    try {
      await dio.put('${ApiConfig.user}/$id', data: updates);
    } catch (e) {
      throw Exception('Failed to update employee: ${e.toString()}');
    }
  }

  // 5. Delete Employee
  Future<void> deleteEmployee(Dio dio, int id) async {
    try {
      await dio.delete('${ApiConfig.user}/$id');
    } catch (e) {
      throw Exception('Failed to delete employee: ${e.toString()}');
    }
  }

  // 5b. Bulk Delete Employees (Client-side concurrent)
  Future<void> bulkDeleteEmployees(Dio dio, List<int> ids) async {
    try {
      await Future.wait(ids.map((id) => deleteEmployee(dio, id)));
    } catch (e) {
      throw Exception('Failed to delete some employees: ${e.toString()}');
    }
  }
  
  // 6. Bulk Upload Users
  Future<Map<String, dynamic>> bulkUploadUsers(Dio dio, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        // 'file' must match the field name expected by Multer on the backend
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dio.post(
        ApiConfig.bulkUpload, 
        data: formData,
        // Dio automatically sets Content-Type to multipart/form-data
      );
      
      return response.data; // { ok: true, report: { ... } }
    } catch (e) {
      throw Exception('Bulk upload failed: ${e.toString()}');
    }
  }
  
  // --- Dropdown Helpers ---

  Future<List<Department>> getDepartments(Dio dio) async {
    final res = await dio.get(ApiConfig.departments);
    if (res.data['departments'] == null) return [];
    return (res.data['departments'] as List).map((x) => Department.fromJson(x)).toList();
  }

  Future<List<Designation>> getDesignations(Dio dio) async {
    final res = await dio.get(ApiConfig.designations);
     if (res.data['designations'] == null) return [];
    return (res.data['designations'] as List).map((x) => Designation.fromJson(x)).toList();
  }

  Future<List<Shift>> getShifts(Dio dio) async {
     final res = await dio.get(ApiConfig.shifts);
     if (res.data['shifts'] == null) return [];
    return (res.data['shifts'] as List).map((x) => Shift.fromJson(x)).toList();
  }
}
