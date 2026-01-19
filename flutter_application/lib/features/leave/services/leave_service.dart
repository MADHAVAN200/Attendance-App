import 'package:dio/dio.dart';
import '../../../shared/services/api_config.dart';
import '../../../shared/services/auth_service.dart';
import '../models/leave_model.dart';
import 'dart:io';

class LeaveService {
  final AuthService _authService;

  LeaveService(this._authService);

  Future<List<Leave>> getMyLeaves() async {
    try {
      final response = await _authService.dio.get(ApiConfig.myLeaves);

      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> data = response.data['leaves'] ?? response.data['data'];
        return data.map((json) => Leave.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch leaves: $e');
    }
  }

  Future<void> applyForLeave(Map<String, dynamic> leaveData, {File? document}) async {
    try {
      FormData formData = FormData.fromMap(leaveData);

      if (document != null) {
        formData.files.add(MapEntry(
          'document',
          await MultipartFile.fromFile(document.path),
        ));
      }

      await _authService.dio.post(ApiConfig.leaves, data: formData);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to apply for leave');
      }
      throw Exception('Failed to apply for leave: $e');
    }
  }

  Future<void> withdrawLeave(int id) async {
    try {
      // Assuming DELETE /leaves/:id or POST /leaves/withdraw/:id
      // React code: await leaveService.withdrawLeave(id);
      await _authService.dio.delete('${ApiConfig.leaves}/$id');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to withdraw leave');
      }
      throw Exception('Failed to withdraw leave: $e');
    }
  }
}
