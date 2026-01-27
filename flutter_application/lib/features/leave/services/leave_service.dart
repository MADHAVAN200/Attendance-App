import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../shared/constants/api_constants.dart';

class LeaveService {
  final Dio _dio;

  LeaveService(this._dio);

  // 1. Get My History
  Future<List<dynamic>> getMyHistory() async {
    try {
      final response = await _dio.get(ApiConstants.leavesMyHistory);
      if (response.statusCode == 200 && (response.data['ok'] == true || response.data['success'] == true)) {
        return response.data['leaves'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch leave history: $e');
    }
  }

  // 2. Submit Leave Request
  Future<void> submitLeaveRequest(Map<String, dynamic> requestData) async {
      dynamic data = requestData;
      
      // Check for file attachment and convert to FormData
      // Check if attachment exists and is not null
      if (requestData.containsKey('attachment') && requestData['attachment'] != null) {
        final attachment = requestData['attachment'];
        
        // Robust check: Check type OR if it looks like a PlatformFile (has bytes/path)
        final isFile = attachment is PlatformFile || attachment.runtimeType.toString().contains('PlatformFile');
        
        if (isFile) {
           final dynamic file = attachment; // Cast to dynamic to avoid type issues if class identity mismatch
           
           // Remove attachment from map to avoid duplicate or error
           final map = Map<String, dynamic>.from(requestData);
           map.remove('attachment');

           final formData = FormData.fromMap(map);
           
           bool added = false;
           // Append file
           if (file.bytes != null) {
             formData.files.add(MapEntry(
               'attachment',
               MultipartFile.fromBytes(file.bytes!, filename: file.name),
             ));
             added = true;
           } else if (file.path != null) {
             formData.files.add(MapEntry(
               'attachment',
               await MultipartFile.fromFile(file.path!, filename: file.name),
             ));
             added = true;
           }
           
           if(added) data = formData;
        } else {
          // If it's something else not encodable, remove it to prevent crash
           final map = Map<String, dynamic>.from(requestData);
           map.remove('attachment');
           data = map;
        }
      }

      await _dio.post(ApiConstants.leavesRequest, data: data);
  }

  // 3. Withdraw Request
  Future<void> withdrawRequest(int id) async {
      await _dio.delete('${ApiConstants.leavesRequest}/$id');
  }

  // 4. Admin - Pending Requests
  Future<List<dynamic>> getPendingRequests() async {
    try {
      final response = await _dio.get(ApiConstants.leavesAdminPending);
      if (response.statusCode == 200 && (response.data['ok'] == true || response.data['success'] == true)) {
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
      if (response.statusCode == 200 && (response.data['ok'] == true || response.data['success'] == true)) {
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
