import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/attendance_record.dart';
import '../models/correction_request.dart';

class AttendanceService {
  final Dio _dio;

  AttendanceService(this._dio);

  // 1. Get My Records
  Future<List<AttendanceRecord>> getMyRecords({String? fromDate, String? toDate}) async {
    try {
      final response = await _dio.get(ApiConstants.attendanceRecords, queryParameters: {
        'date_from': fromDate,
        'date_to': toDate,
      });

      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> list = response.data['data'];
        return list.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch records: $e');
    }
  }

  // 1.5 Get Admin Records
  Future<List<AttendanceRecord>> getAdminAttendanceRecords(String date) async {
    try {
      final response = await _dio.get(ApiConstants.adminAttendanceRecords, queryParameters: {
        'date_from': date,
        'date_to': date,
        'limit': 200, 
      });

      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> list = response.data['data'];
        return list.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch live records: $e');
    }
  }

  // 2. Time In
  Future<Map<String, dynamic>> timeIn({
    required double latitude,
    required double longitude,
    required double accuracy,
    required File imageFile,
    String? lateReason,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "accuracy": accuracy.toString(),
        if (lateReason != null) "late_reason": lateReason,
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(ApiConstants.attendanceTimeIn, data: formData);
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 3. Time Out
  Future<Map<String, dynamic>> timeOut({
    required double latitude,
    required double longitude,
    required double accuracy,
    required File imageFile,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "accuracy": accuracy.toString(),
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(ApiConstants.attendanceTimeOut, data: formData);
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }
  
  // 4. Correction Requests (New)

  // Create Request
  Future<void> createCorrectionRequest({
    int? attendanceId, // OPTIONAL
    required String correctionType, // 'missed_punch', 'late_entry', 'early_exit'
    required String requestDate, // YYYY-MM-DD
    required String reason,
  }) async {
    try {
      await _dio.post(ApiConstants.attendanceCorrectionRequest, data: {
        "attendance_id": attendanceId,
        "correction_type": correctionType,
        "request_date": requestDate,
        "reason": reason,
      });
    } catch (e) {
      throw _parseError(e);
    }
  }

  // Fetch All Requests
  Future<List<CorrectionRequest>> getCorrectionRequests() async {
    try {
      final response = await _dio.get(ApiConstants.attendanceCorrectionRequests);
      if (response.statusCode == 200 && response.data['success']) {
         final List<dynamic> list = response.data['requests'] ?? [];
         return list.map((json) => CorrectionRequest.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw _parseError(e);
    }
  }
  
  // Get Request Detail
  Future<Map<String, dynamic>> getCorrectionRequestDetail(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.attendanceCorrectionRequest}/$id');
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['request'];
      }
      throw Exception('Request not found');
    } catch (e) {
      throw _parseError(e);
    }
  }

  // Update Request Status
  Future<void> updateCorrectionRequestStatus(int id, String status, String comments) async {
    try {
      await _dio.patch('${ApiConstants.attendanceCorrectRequestUpdate}/$id', data: {
        "status": status,
        "review_comments": comments
      });
    } catch (e) {
      throw _parseError(e);
    }
  }
  
  // 5. Simulation (Dev Only)
  Future<void> simulateTimeIn(Map<String, dynamic> data) async {
      await _dio.post(ApiConstants.simulateTimeIn, data: FormData.fromMap(data));
  }
  
  Future<void> simulateTimeOut(Map<String, dynamic> data) async {
      await _dio.post(ApiConstants.simulateTimeOut, data: FormData.fromMap(data));
  }

  Exception _parseError(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final msg = e.response?.data['message'] ?? e.message;
      return Exception(msg);
    }
    return Exception(e.toString());
  }
}
