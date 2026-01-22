import 'package:dio/dio.dart';
import '../../../shared/constants/api_constants.dart';

class LeaveService {
  final Dio _dio;

  LeaveService(this._dio);

  // 1. Get My History
  Future<List<dynamic>> getMyHistory() async {
    try {
      final response = await _dio.get(ApiConstants.leavesMyHistory);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['leaves'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch leave history: $e');
    }
  }

  // 2. Submit Leave Request
  Future<void> submitLeaveRequest(Map<String, dynamic> requestData) async {
    try {
      await _dio.post(ApiConstants.leavesRequest, data: requestData);
    } catch (e) {
      throw Exception('Failed to submit leave request: $e');
    }
  }

  // 3. Withdraw Request
  Future<void> withdrawRequest(int id) async {
    try {
      await _dio.delete('${ApiConstants.leavesRequest}/$id');
    } catch (e) {
      throw Exception('Failed to withdraw request: $e');
    }
  }

  // 4. Admin - Pending Requests
  Future<List<dynamic>> getPendingRequests() async {
    try {
      final response = await _dio.get(ApiConstants.leavesAdminPending);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['requests'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch pending requests: $e');
    }
  }

  // 5. Admin - History
  Future<List<dynamic>> getAdminHistory({String status = 'Approved'}) async {
    try {
      final response = await _dio.get(ApiConstants.leavesAdminHistory, queryParameters: {
        'status': status
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['history'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch admin leave history: $e');
    }
  }

  // 6. Admin - Approve/Reject (Update Status)
  Future<void> updateRequestStatus(int id, String status, {String? payType, String? comment}) async {
    try {
      await _dio.put('${ApiConstants.leavesAdminStatus}/$id', data: {
        'status': status,
        if (payType != null) 'pay_type': payType,
        if (comment != null) 'admin_comment': comment,
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }
}
