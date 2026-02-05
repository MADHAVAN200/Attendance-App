
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/auth_service.dart';
import '../models/correction_request.dart';

class AttendanceCorrectionService {
  final AuthService _authService;
  final String _baseUrl = 'http://localhost:5000/api/attendance'; // Replace with actual API URL

  AttendanceCorrectionService(this._authService);

  // Helper to get headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.token}',
      };

  // 1. Submit Request
  Future<Map<String, dynamic>> submitCorrectionRequest(AttendanceCorrectionRequest request) async {
    try {
      // Mock Implementation
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true, 'message': 'Correction request submitted'};
      
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/correction-request'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit request: ${response.body}');
      }
      */
    } catch (e) {
      throw Exception('Error submitted correction request: $e');
    }
  }

  // 2. Get Requests (Admin: all, Employee: mine)
  Future<List<AttendanceCorrectionRequest>> getCorrectionRequests({String? status, int page = 1, int limit = 10}) async {
    try {
      // Mock Implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate some dummy data
      return List.generate(5, (index) => AttendanceCorrectionRequest(
        id: 'mock-$index',
        userId: 'user-$index',
        userName: 'User $index',
        requestDate: DateTime.now().subtract(Duration(days: index)),
        type: index % 2 == 0 ? CorrectionType.missedPunch : CorrectionType.overtime,
        method: CorrectionMethod.fix,
        reason: 'Forgot to punch out due to rush',
        status: index == 0 ? RequestStatus.pending : (index == 1 ? RequestStatus.approved : RequestStatus.rejected),
        requestedTimeIn: '09:00',
        requestedTimeOut: '18:00',
      ));

      /*
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };
      
      final uri = Uri.parse('$_baseUrl/correction-requests').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['requests'] as List).map((x) => AttendanceCorrectionRequest.fromJson(x)).toList();
      } else {
         throw Exception('Failed to fetch requests: ${response.body}');
      }
      */
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  // 3. Update Status (Admin Only)
  Future<void> updateCorrectionStatus(String requestId, RequestStatus status, String comments, {
    String? overrideTimeIn,
    String? overrideTimeOut,
  }) async {
    try {
       // Mock Implementation
      await Future.delayed(const Duration(seconds: 1));
      return;

      /*
      final body = {
        'status': status.toString().split('.').last,
        'review_comments': comments,
        if (overrideTimeIn != null) 'requested_time_in': overrideTimeIn,
        if (overrideTimeOut != null) 'requested_time_out': overrideTimeOut,
      };

      final response = await http.patch(
        Uri.parse('$_baseUrl/correct-request/$requestId'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update status: ${response.body}');
      }
      */
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }
}
