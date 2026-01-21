import 'package:dio/dio.dart';
import 'dart:io';
import 'api_client.dart';
import '../shared/models/leave_model.dart';

class LeaveService {
  final ApiClient _client = ApiClient();

  // --- Employee ---
  Future<List<Leave>> getMyLeaveHistory() async {
    try {
      final response = await _client.get('/leaves/my-history');
      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => Leave.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching leave history: $e");
    }
    return [];
  }

  Future<void> submitLeaveRequest({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    File? document, // Added support for file
  }) async {
    // Check if file is provided, use FormData
    if (document != null) {
      String fileName = document.path.split('/').last;
      FormData formData = FormData.fromMap({
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
        "document": await MultipartFile.fromFile(document.path, filename: fileName),
      });
      await _client.post('/leaves/request', data: formData);
    } else {
      // JSON body
      await _client.post('/leaves/request', data: {
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
      });
    }
  }

  Future<void> withdrawRequest(int leaveId) async {
    await _client.delete('/leaves/request/$leaveId');
  }

  // --- Admin ---
  Future<List<dynamic>> getPendingRequests() async {
    try {
      final response = await _client.get('/leaves/admin/pending');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching pending leaves: $e");
    }
    return [];
  }

  Future<List<dynamic>> getAdminHistory({String? status}) async {
    try {
      final response = await _client.get('/leaves/admin/history', queryParameters: {
        if (status != null) 'status': status,
      });
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching admin leave history: $e");
    }
    return [];
  }

  Future<void> updateLeaveStatus({
    required int leaveId,
    required String status, // Approved / Rejected
    required String payType, // Paid / Unpaid
    required String adminComment,
  }) async {
    await _client.put('/leaves/admin/status/$leaveId', data: {
      "status": status,
      "pay_type": payType,
      "admin_comment": adminComment,
    });
  }
}
