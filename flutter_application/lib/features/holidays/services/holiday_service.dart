import 'package:dio/dio.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/holiday_model.dart';

class HolidayService {
  final Dio _dio;

  HolidayService(this._dio);

  // 1. Get All Holidays
  Future<List<Holiday>> getHolidays() async {
    try {
      final response = await _dio.get(ApiConstants.holidays);
      if (response.statusCode == 200 && response.data['ok'] == true) {
        final List<dynamic> data = response.data['holidays'];
        return data.map((json) => Holiday.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load holidays: $e');
    }
  }

  // 2. Add Holiday (Single)
  Future<void> addHoliday(Map<String, dynamic> holidayData) async {
    try {
      await _dio.post(ApiConstants.holidays, data: holidayData);
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 2.1 Add Bulk Holidays
  Future<void> addBulkHolidays(List<Map<String, dynamic>> holidays) async {
    try {
      await _dio.post(ApiConstants.holidays, data: {'holidays': holidays});
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 3. Update Holiday
  Future<void> updateHoliday(int id, Map<String, dynamic> updates) async {
    try {
      await _dio.put('${ApiConstants.holidays}/$id', data: updates);
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 4. Delete Holiday (Supports Bulk)
  Future<void> deleteHolidays(List<int> ids) async {
    try {
      await _dio.delete(ApiConstants.holidays, data: {'ids': ids});
    } catch (e) {
      throw _parseError(e);
    }
  }

  Exception _parseError(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final msg = e.response?.data['message'] ?? e.message;
      return Exception(msg);
    }
    return Exception(e.toString());
  }
}
