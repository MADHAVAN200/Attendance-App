import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../shared/services/api_config.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final Dio _dio;

  AttendanceService(this._dio);

  // 1. Get My Records
  Future<List<AttendanceRecord>> getMyRecords({String? fromDate, String? toDate}) async {
    try {
      final response = await _dio.get(ApiConfig.myRecords, queryParameters: {
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
      final response = await _dio.get(ApiConfig.adminAttendance, queryParameters: {
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
    required File imageFile,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      // Dio needs MultipartFile for file uploads
      FormData formData = FormData.fromMap({
        "latitude": latitude,
        "longitude": longitude,
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(ApiConfig.timeIn, data: formData);
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 3. Time Out
  Future<Map<String, dynamic>> timeOut({
    required double latitude,
    required double longitude,
    required File imageFile,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "latitude": latitude,
        "longitude": longitude,
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(ApiConfig.timeOut, data: formData);
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }

  Exception _parseError(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      // Try to get message from response
      final msg = e.response?.data['message'] ?? e.message;
      return Exception(msg);
    }
    return Exception(e.toString());
  }
}
