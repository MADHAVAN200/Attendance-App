import 'package:dio/dio.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/holiday_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HolidayService {
  final Dio _dio;
  static const String _cacheKey = 'cached_holidays_data';
  static const String _timestampKey = 'cached_holidays_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  HolidayService(this._dio);

  // 1. Get All Holidays (with Caching)
  Future<List<Holiday>> getHolidays({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString(_cacheKey);
        final timestamp = prefs.getInt(_timestampKey);

        if (jsonString != null && timestamp != null) {
          final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (DateTime.now().difference(cachedTime) < _cacheDuration) {
             final List<dynamic> data = jsonDecode(jsonString);
             return data.map((json) => Holiday.fromJson(json)).toList();
          }
        }
      }

      final response = await _dio.get(ApiConstants.holidays);
      if (response.statusCode == 200 && response.data['ok'] == true) {
        final List<dynamic> data = response.data['holidays'];
        // Cache it
        _cacheHolidays(data);
        return data.map((json) => Holiday.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load holidays: $e');
    }
  }

  Future<void> _cacheHolidays(List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(data));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_timestampKey);
  }

  // 2. Add Holiday (Single)
  Future<void> addHoliday(Map<String, dynamic> holidayData) async {
    try {
      final response = await _dio.post(ApiConstants.holidays, data: holidayData);
      if (response.data != null && response.data['ok'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to add holiday');
      }
      await _clearCache(); // Invalidate cache
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 2.1 Add Bulk Holidays
  Future<void> addBulkHolidays(List<Map<String, dynamic>> holidays) async {
    try {
      final response = await _dio.post(ApiConstants.holidays, data: {'holidays': holidays});
      if (response.data != null && response.data['ok'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to add holidays');
      }
      await _clearCache(); // Invalidate cache
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 3. Update Holiday
  Future<void> updateHoliday(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('${ApiConstants.holidays}/$id', data: updates);
      if (response.data != null && response.data['ok'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update holiday');
      }
      await _clearCache(); // Invalidate cache
    } catch (e) {
      throw _parseError(e);
    }
  }

  // 4. Delete Holiday (Supports Bulk)
  Future<void> deleteHolidays(List<int> ids) async {
    try {
      final response = await _dio.delete(ApiConstants.holidays, data: {'ids': ids});
      if (response.data != null && response.data['ok'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete holidays');
      }
      await _clearCache(); // Invalidate cache
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
