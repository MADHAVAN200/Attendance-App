import 'package:dio/dio.dart';
import 'dart:io';
import 'api_client.dart';
import '../shared/models/attendance_model.dart';

class AttendanceService {
  final ApiClient _client = ApiClient();

  // --- Attendance Records (Admin) ---
  Future<List<dynamic>> getAdminAttendanceRecords({
    required String dateFrom,
    required String dateTo,
    int limit = 100,
    int? userId,
  }) async {
    try {
      final response = await _client.get('/attendance/records/admin', queryParameters: {
        'date_from': dateFrom,
        'date_to': dateTo,
        'limit': limit,
        if (userId != null) 'user_id': userId,
      });
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching admin records: $e");
    }
    return [];
  }

  // --- Correction Requests ---
  Future<void> createCorrectionRequest({
    required int attendanceId,
    required String correctionType,
    required String requestDate, // YYYY-MM-DD
    required String reason,
  }) async {
    await _client.post('/attendance/correction-request', data: {
      "attendance_id": attendanceId,
      "correction_type": correctionType,
      "request_date": requestDate,
      "reason": reason,
    });
  }

  Future<List<dynamic>> getCorrectionRequests() async {
    try {
      final response = await _client.get('/attendance/correction-requests');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching correction requests: $e");
    }
    return [];
  }

  Future<void> updateCorrectionStatus(int requestId, String status, String comments) async {
    await _client.patch('/attendance/correct-request/$requestId', data: {
      "status": status,
      "review_comments": comments,
    });
  }

  // --- Employee / User Attendance ---

  Future<List<AttendanceRecord>> getMyRecords({
    required String fromDate, 
    required String toDate,
  }) async {
    try {
      final response = await _client.get('/attendance/records/my', queryParameters: {
        'date_from': fromDate,
        'date_to': toDate,
      });

      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching my records: $e");
    }
    return [];
  }

  Future<void> timeIn({
    required double latitude,
    required double longitude,
    required File imageFile,
  }) async {
    String fileName = imageFile.path.split('/').last;
    
    FormData formData = FormData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    await _client.post('/attendance/time-in', data: formData);
  }

  Future<void> timeOut({
    required double latitude,
    required double longitude,
    required File imageFile,
  }) async {
    String fileName = imageFile.path.split('/').last;
    
    FormData formData = FormData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    await _client.post('/attendance/time-out', data: formData);
  }
}
