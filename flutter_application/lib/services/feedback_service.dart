import 'package:dio/dio.dart';
import 'api_client.dart';

class FeedbackService {
  final ApiClient _client = ApiClient();

  // --- Feedback ---
  Future<void> submitFeedback({
    required String title,
    required String description,
    required String type, // BUG or FEEDBACK
    List<String> filePaths = const [],
  }) async {
    Map<String, dynamic> dataMap = {
      "title": title,
      "description": description,
      "type": type,
    };

    if (filePaths.isNotEmpty) {
      // Handle multiple files
      List<MultipartFile> files = [];
      for (String path in filePaths) {
        String fileName = path.split('/').last;
        files.add(await MultipartFile.fromFile(path, filename: fileName));
      }
      dataMap['files'] = files; 
    }

    FormData formData = FormData.fromMap(dataMap);
    await _client.post('/feedback', data: formData);
  }

  Future<List<dynamic>> getFeedbackAdmin({String status = 'OPEN', String? type}) async {
    try {
      final response = await _client.get('/feedback', queryParameters: {
        'status': status,
        if (type != null) 'type': type,
      });
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching feedback: $e");
    }
    return [];
  }

  // --- Notifications ---
  Future<List<dynamic>> getNotifications({bool unreadOnly = false, int limit = 20}) async {
    try {
      final response = await _client.get('/notifications', queryParameters: {
        'unread_only': unreadOnly,
        'limit': limit,
      });
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
    return [];
  }

  Future<void> markAsRead(int notificationId) async {
    await _client.put('/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _client.put('/notifications/read-all');
  }
}
