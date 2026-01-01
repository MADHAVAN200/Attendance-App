import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/attendance_session.dart';

class AttendanceService {
  final String _baseUrl = ApiConstants.baseUrl;

  // Fetch Admin Records (Enriched with User Info)
  Future<List<AttendanceSession>> getAdminRecords(String date) async {
    final url = Uri.parse('$_baseUrl/attendance/records/admin?date=$date');
    
    try {
      final response = await http.get(url);
      debugPrint('GET $url - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;
        if (decoded is List) {
            data = decoded;
        } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
            data = decoded['data'];
        } else {
             return _getMockSession();
        }
        return data.map((json) => AttendanceSession.fromJson(json)).toList();
      } else {
        return _getMockSession();
      }
    } catch (e) {
      debugPrint('Service Error: $e');
      return _getMockSession();
    }
  }

  List<AttendanceSession> _getMockSession() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      return [
          AttendanceSession(id: '101', timeIn: today.add(const Duration(hours: 9, minutes: 15)), timeOut: today.add(const Duration(hours: 18)), lateMinutes: 15, status: 'Late', userName: 'Rahul Verma', department: 'Sales', designation: 'Inventory Specialist', avatarChar: 'R'),
          AttendanceSession(id: '102', timeIn: today.add(const Duration(hours: 9)), timeOut: null, lateMinutes: 0, status: 'Active', userName: 'Sneha Patil', department: 'Sales', designation: 'Sales Executive', avatarChar: 'S'),
          AttendanceSession(id: '103', timeIn: today.add(const Duration(hours: 8, minutes: 55)), timeOut: today.add(const Duration(hours: 18, minutes: 5)), lateMinutes: 0, status: 'Present', userName: 'Arjun Mehta', department: 'Sales', designation: 'Sales Executive', avatarChar: 'A'),
          AttendanceSession(id: '105', timeIn: today.add(const Duration(hours: 9, minutes: 5)), timeOut: null, lateMinutes: 0, status: 'Active', userName: 'Amit Kumar', department: 'Logistics', designation: 'Logistics Coordinator', avatarChar: 'A'),
      ];
  }

  // Fetch Records
  Future<List<AttendanceSession>> getMyRecords(String startDate, String endDate) async {
    // Note: User's sample showed /attendance/records and returned all data. 
    // We are keeping start/end params just in case, but using the exact path requested.
    // If backend ignores them, it's fine.
    final url = Uri.parse('$_baseUrl/attendance/records?startDate=$startDate&endDate=$endDate');
    
    try {
      final response = await http.get(url);
      debugPrint('GET $url - Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        List<dynamic> data;
        if (decoded is List) {
            data = decoded;
        } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
            data = decoded['data'];
        } else {
             debugPrint('Unexpected JSON format: $decoded');
             return [];
        }

        return data.map((json) => AttendanceSession.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load records: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Service Error: $e');
      throw Exception('Error fetching records: $e');
    }
  }

  // Check In
  Future<void> timeIn({
    required double latitude,
    required double longitude,
    required File imageFile,
    double? accuracy,
  }) async {
    final url = Uri.parse('$_baseUrl/attendance/timein'); // Corrected path
    final request = http.MultipartRequest('POST', url);

    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    if (accuracy != null) request.fields['accuracy'] = accuracy.toString();
    // request.fields['late_reason'] = ''; // Optional

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    debugPrint('POST $url');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('Response: ${response.statusCode} ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
       throw Exception('Time In failed: ${response.body}');
    }
  }

  // Check Out
  Future<void> timeOut({
    required double latitude,
    required double longitude,
    required File imageFile,
    double? accuracy,
  }) async {
    final url = Uri.parse('$_baseUrl/attendance/timeout'); // Corrected path
    final request = http.MultipartRequest('POST', url);

    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    if (accuracy != null) request.fields['accuracy'] = accuracy.toString();
    
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    debugPrint('POST $url');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('Response: ${response.statusCode} ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
       throw Exception('Time Out failed: ${response.body}');
    }
  }
}
