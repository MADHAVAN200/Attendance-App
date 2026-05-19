import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/attendance_record.dart';
import '../models/correction_request.dart';

class AttendanceService {
  final Dio _dio;

  AttendanceService(this._dio);

  // 1. Get My Records
  Future<List<AttendanceRecord>> getMyRecords({String? fromDate, String? toDate, String? userId, int? limit}) async {
    try {
      final response = await _dio.get(ApiConstants.attendanceRecords, queryParameters: {
        'date_from': fromDate,
        'date_to': toDate,
        if (userId != null) 'user_id': userId,
        if (limit != null) 'limit': limit,
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
      String fileName = p.basename(imageFile.path);
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      
      FormData formData = FormData.fromMap({
        "latitude": latitude.toStringAsFixed(4),
        "longitude": longitude.toStringAsFixed(4), 
        "accuracy": accuracy.toStringAsFixed(2), // Re-added
        if (lateReason != null) "late_reason": lateReason,
        "image": await MultipartFile.fromFile(
          imageFile.path, 
          filename: fileName,
        ),
      });

      debugPrint("AttService: TimeIn Request Data: ${formData.fields.map((e) => "${e.key}: ${e.value}")}");

      final response = await _dio.post(ApiConstants.attendanceTimeIn, data: formData);
      debugPrint("AttService: TimeIn Success Response Data: ${response.data}"); 
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
      String fileName = p.basename(imageFile.path);
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      
      FormData formData = FormData.fromMap({
        "latitude": latitude.toStringAsFixed(4),
        "longitude": longitude.toStringAsFixed(4),
        "accuracy": accuracy.toStringAsFixed(2), // Re-added
        "image": await MultipartFile.fromFile(
          imageFile.path, 
          filename: fileName,
        ),
      });

      debugPrint("AttService: TimeOut Request Data: ${formData.fields}");

      final response = await _dio.post(ApiConstants.attendanceTimeOut, data: formData);
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }
  
  // 4. Correction Requests (New)

  // Submit Request (Employee)
  Future<void> submitCorrectionRequest({
    required String requestDate, // YYYY-MM-DD
    required String correctionType, // missed_punch, incorrect_time, regularization
    required String correctionMethod, // add_session, reset
    required String reason,
    required Map<String, dynamic> correctionData,
    double? latitude,
    double? longitude,
    List<dynamic>? attachments, // PlatformFile or File
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        "request_date": requestDate,
        "correction_type": correctionType,
        "correction_method": correctionMethod,
        "reason": reason,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
        ...correctionData,
      };

      dynamic data = dataMap;

      // Handle Attachments
      if (attachments != null && attachments.isNotEmpty) {
        final formData = FormData.fromMap(dataMap.map((key, value) {
          // Flatten lists/maps for FormData if needed, or send as JSON string if API expects it.
          // Dio FormData handles primitive types well. Complex nested objects might need JSON encoding.
          if (value is List || value is Map) {
            return MapEntry(key, value); // Dio might not serialize this automatically for FormData
            // If API expects 'sessions' as JSON string inside FormData:
            // return MapEntry(key, jsonEncode(value));
            // Assuming Dio handles it or backend handles array indices correction_data[sessions][0]...
          }
          return MapEntry(key, value);
        }));

        // Manually handle complex correctionData for FormData if strictly required by Dio/Backend
        // For now, attempting standard Dio FormData structure. 
        // Note: Dio's FormData.fromMap might NOT recursively process nested Lists/Maps into array syntax.
        // If correctionData contains 'sessions', we might need to be careful.
        // Safe bet: If using FormData, ensure complex fields are handled correctly.
        
        // Add files
        for (var i = 0; i < attachments.length; i++) {
          final attachment = attachments[i];
          // Check if it's PlatformFile (from file_picker)
           if (attachment.path != null) {
            final filename = attachment.name;
            formData.files.add(MapEntry(
              'attachments[]', // Array syntax common for multiple files
              await MultipartFile.fromFile(attachment.path!, filename: filename),
            ));
          }
        }
        data = formData;
      }

      await _dio.post(ApiConstants.attendanceCorrectionRequest, data: data);
    } catch (e) {
      throw _parseError(e);
    }
  }

  // Fetch All Requests
  Future<List<AttendanceCorrectionRequest>> getCorrectionRequests({
    String? status, 
    String? userId, 
    String? date,
    int? month,
    int? year,
    int? page,
    int? limit,
    String? dateFrom, // Kept for backward compatibility if needed by other views
    String? dateTo,
  }) async {
    try {
      final response = await _dio.get(ApiConstants.attendanceCorrectionRequests, queryParameters: {
        if (status != null) 'status': status,
        if (userId != null) 'user_id': userId,
        if (date != null) 'date': date,
        if (month != null) 'month': month,
        if (year != null) 'year': year,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      });
      
      if (response.statusCode == 200 && response.data != null && response.data is Map) {
         final dynamic data = response.data['data'];
         if (data is List) {
           return data.map((json) => AttendanceCorrectionRequest.fromJson(json as Map<String, dynamic>)).toList();
         }
      }
      return [];
    } catch (e) {
      throw _parseError(e);
    }
  }
  
  // Get Request Detail
  Future<AttendanceCorrectionRequest> getCorrectionRequestDetail(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.attendanceCorrectionRequest}/$id');
      if (response.statusCode == 200 && response.data != null && response.data is Map) {
        // Handle both wrapped {data: {...}} and unwrapped {...} responses
        final dynamic data = response.data['data'] ?? response.data;
        if (data is Map) {
          return AttendanceCorrectionRequest.fromJson(Map<String, dynamic>.from(data));
        }
      }
      throw Exception('Correction request not found or invalid response');
    } catch (e) {
      throw _parseError(e);
    }
  }

  // Process Request (Admin Only)
  Future<void> processCorrectionRequest(String id, {
    required String status, // approved, rejected
    String? reviewComments,
    String? overrideMethod,
    String? requestDate,
    List<Map<String, String>>? sessions, // for add_session
    String? resetTimeIn, // for reset
    String? resetTimeOut, // for reset
  }) async {
    try {
      final payload = {
        "status": status,
        if (reviewComments != null) "review_comments": reviewComments,
        if (overrideMethod != null) "correction_method": overrideMethod,
        if (requestDate != null) "request_date": requestDate,
        if (sessions != null) "sessions": sessions,
        if (resetTimeIn != null) "reset_time_in": resetTimeIn,
        if (resetTimeOut != null) "reset_time_out": resetTimeOut,
      };

      await _dio.patch('${ApiConstants.attendanceCorrectRequestUpdate}/$id', data: payload);
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

  // 6. Export My Report
  Future<Uint8List> exportMyReport(String month) async {
    try {
      final response = await _dio.get(
        ApiConstants.attendanceRecordExport,
        queryParameters: {'month': month},
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      throw _parseError(e);
    }
  }

  Exception _parseError(dynamic e) {
    if (e is DioException) {
      debugPrint("AttService Error: ${e.response?.statusCode} - ${e.response?.data}");
      if (e.response?.data != null && e.response!.data is Map) {
        final msg = e.response?.data['message'] ?? e.message;
        return Exception(msg);
      }
      return Exception(e.message ?? e.toString());
    }
    return Exception(e.toString());
  }
}
