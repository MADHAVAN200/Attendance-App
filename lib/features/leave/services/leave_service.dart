import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../shared/constants/api_constants.dart';
import '../models/leave_request_model.dart';

class LeaveService {
  final Dio _dio;

  LeaveService(this._dio);

  // 1. Get My History
  Future<List<LeaveRequest>> getMyHistory() async {
    try {
      final response = await _dio.get(ApiConstants.leavesMyHistory);
      debugPrint('LeaveService (RAW): ${response.data}');
      if (response.statusCode == 200 && (response.data['ok'] == true || response.data['success'] == true)) {
        final List<dynamic> leavesJson = response.data['leaves'] ?? [];
        return leavesJson.map((e) => LeaveRequest.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch leave history: $e');
    }
  }

  // 2. Submit Leave Request
  Future<void> submitLeaveRequest(Map<String, dynamic> requestData) async {
      dynamic data = requestData;
      
      // Check for file attachments and convert to FormData
      if (requestData.containsKey('attachments') && requestData['attachments'] != null) {
        final List<dynamic> attachments = requestData['attachments'] is List ? requestData['attachments'] : [requestData['attachments']];
        
        final map = Map<String, dynamic>.from(requestData);
        map.remove('attachments');

        final formData = FormData.fromMap(map);
        
        for (var attachment in attachments) {
          final isFile = attachment is PlatformFile || attachment.runtimeType.toString().contains('PlatformFile');
          if (isFile) {
            final dynamic file = attachment;
            if (file.bytes != null) {
              formData.files.add(MapEntry(
                'attachments',
                MultipartFile.fromBytes(file.bytes!, filename: file.name),
              ));
            } else if (file.path != null) {
              formData.files.add(MapEntry(
                'attachments',
                await MultipartFile.fromFile(file.path!, filename: file.name),
              ));
            }
          }
        }
        data = formData;
      }

      await _dio.post(ApiConstants.leavesRequest, data: data);
  }

  // 3. Withdraw Request
  Future<void> withdrawRequest(int id) async {
      try {
        final url = '${ApiConstants.leavesRequest}/$id';
        debugPrint('LeaveService: Withdrawing request at $url (ID: $id)');
        await _dio.delete(url);
      } catch (e) {
        if (e is DioException) {
           throw Exception('Failed to withdraw request: ${e.response?.statusCode} - ${e.response?.data}');
        }
        rethrow;
      }
  }

  // 4. Admin - Pending Requests
  Future<List<LeaveRequest>> getPendingRequests() async {
    try {
      final response = await _dio.get(ApiConstants.leavesAdminPending);
      if (response.statusCode == 200 && (response.data['ok'] == true || response.data['success'] == true)) {
        final List<dynamic> hitsJson = response.data['requests'] ?? [];
        return hitsJson.map((e) => LeaveRequest.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch pending requests: $e');
    }
  }

  // 5. Admin - History
  Future<List<LeaveRequest>> getAdminHistory({int? userId, String? status, DateTime? startDate, DateTime? endDate}) async {
    try {
      final Map<String, dynamic> query = {};
      
      if (userId != null) query['user_id'] = userId;
      if (status != null && status.isNotEmpty && status != 'All') query['status'] = status;
      if (startDate != null) query['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) query['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await _dio.get(ApiConstants.leavesAdminHistory, queryParameters: query);
      
      if (response.statusCode == 200 && (response.data['ok'] == true || response.data['success'] == true)) {
         // The user sample had "history" key
        final List<dynamic> hitsJson = response.data['history'] ?? [];
        return hitsJson.map((e) => LeaveRequest.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch admin leave history: $e');
    }
  }

  // 6. Admin - Approve/Reject (Update Status)
  Future<void> updateRequestStatus(int id, String status, {String? payType, int? payPercentage, String? comment}) async {
    try {
      final data = {
        'status': status,
        if (payType != null) 'pay_type': payType,
        if (payPercentage != null) 'pay_percentage': payPercentage,
        if (comment != null) 'admin_comment': comment,
      };
      
      await _dio.put('${ApiConstants.leavesAdminStatus}/$id', data: data);
    } catch (e) {
      if (e is DioException) {
         throw Exception('Failed to update request status: ${e.response?.data ?? e.message}');
      }
      throw Exception('Failed to update request status: $e');
    }
  }
}
