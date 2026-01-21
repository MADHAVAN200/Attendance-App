import 'package:dio/dio.dart';
import 'api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>?> getDashboardStats({String range = 'weekly'}) async {
    try {
      final response = await _client.get('/admin/dashboard-stats', queryParameters: {'range': range});
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching dashboard stats: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPreview({
    required String type,
    String? month,
    String? date,
  }) async {
    try {
      final response = await _client.get('/admin/reports/preview', queryParameters: {
        'type': type,
        if (month != null) 'month': month,
        if (date != null) 'date': date,
      });
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data; // Return the whole wrapper or data
      }
    } catch (e) {
      print("Error fetching report preview: $e");
    }
    return null;
  }

  // Download Report
  Future<String?> downloadReport({
    required String type,
    String? month,
    String? date,
    String format = 'pdf', 
  }) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
         try {
            // Try external storage for Android (visible downloads)
            // Note: path_provider getExternalStorageDirectory might return null on some API levels
            // or require permissions. 
            // The existing code used it, so we preserve behavior.
            dir = await getExternalStorageDirectory(); 
         } catch (_) {}
      }
      dir ??= await getApplicationDocumentsDirectory();

      String fileName = "Report_${type}_${DateTime.now().millisecondsSinceEpoch}.$format";
      String savePath = "${dir.path}/$fileName";

      final response = await _client.get(
        '/admin/reports/download',
        queryParameters: {
          'type': type,
          if (month != null) 'month': month,
          if (date != null) 'date': date,
          'format': format,
        },
        options: Options(
          responseType: ResponseType.bytes, 
        ),
      );

      if (response.statusCode == 200) {
        File file = File(savePath);
        await file.writeAsBytes(response.data);
        return savePath;
      }
    } catch (e) {
      print("Error downloading report: $e");
      // Optional: Logic to create Mock file if needed, 
      // but sticking to standard behavior first.
    }
    return null;
  }
}
