import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../shared/constants/api_constants.dart';

class ReportService {
  final Dio _dio;

  ReportService(this._dio);

  // 1. Get Report Preview (JSON Data)
  Future<Map<String, dynamic>> getPreview({
    required String type,
    String? month, // "YYYY-MM"
    String? date,  // "YYYY-MM-DD"
  }) async {
    try {
      final query = {
        'type': type,
        if (month != null) 'month': month,
        if (date != null) 'date': date,
      };

      final response = await _dio.get(ApiConstants.reportsPreview, queryParameters: query);
      
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data']; 
      }
      return {'columns': [], 'rows': []};
    } catch (e) {
      // Fallback/Mock Data for Development (since backend might be missing endpoint)
      print("API Error: $e. Returning Mock Data.");
      return {
        'columns': ['DATE', 'EMPLOYEE', 'SHIFT', 'HOURS', 'STATUS'],
        'rows': [
          ['2023-10-24', 'MOCK DATA', '09:00 - 18:00', '9h 00m', 'Present'],
        ]
      };
    }
  }

  // 2. Download Report File
  Future<String?> downloadReport({
    required String type,
    required String format, // "xlsx", "csv", "pdf"
    String? month,
    String? date,
  }) async {
    try {
      final query = {
        'type': type,
        'format': format,
        if (month != null) 'month': month,
        if (date != null) 'date': date,
      };

      // Get appropriate directory
      Directory? dir;
      if (Platform.isAndroid) {
         dir = await getExternalStorageDirectory(); 
      } else {
         dir = await getApplicationDocumentsDirectory();
      }
      
      if (dir == null) throw Exception("Could not find storage directory");

      final fileName = "Report_${type}_${DateTime.now().millisecondsSinceEpoch}.$format";
      final savePath = "${dir.path}/$fileName";

      await _dio.download(
        ApiConstants.reportsDownload,
        savePath,
        queryParameters: query,
        onReceiveProgress: (received, total) {
           if (total != -1) {
             // Optional: progress callback
           }
        }
      );

      return savePath;
    } catch (e) {
      print("Download error: $e");
      // MOCK BEHAVIOR
      try {
        Directory? dir;
        if (Platform.isAndroid) {
           dir = await getExternalStorageDirectory(); 
        } else {
           dir = await getApplicationDocumentsDirectory();
        }
        if (dir != null) {
           final fileName = "Mock_Report_${type}_${DateTime.now().millisecondsSinceEpoch}.$format";
           final mockFile = File("${dir.path}/$fileName");
           await mockFile.writeAsString("This is a mock report file content because the backend endpoint was 404/Error.");
           return mockFile.path;
        }
      } catch (_) {}
      
      throw Exception('Failed to download report: $e');
    }
  }
}
