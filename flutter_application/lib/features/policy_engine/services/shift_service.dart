import 'package:dio/dio.dart';
import '../models/shift_model.dart';
import '../../../shared/services/api_config.dart';

class ShiftService {
  final Dio _dio;

  ShiftService(this._dio);

  // 1. Get All Shifts
  Future<List<Shift>> getShifts() async {
    try {
      final response = await _dio.get(ApiConfig.shifts);
      if (response.statusCode == 200 && (response.data['ok'] == true || response.data['success'] == true)) {
        final List<dynamic> list = response.data['shifts'];
        return list.map((j) => Shift.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load shifts: $e');
    }
  }

  // 2. Create Shift
  Future<void> createShift(Shift shift) async {
    try {
      await _dio.post(ApiConfig.shifts, data: shift.toJson());
    } catch (e) {
      throw Exception('Failed to create shift: $e');
    }
  }

  // 3. Update Shift
  Future<void> updateShift(int id, Shift shift) async {
    try {
      await _dio.put('${ApiConfig.shifts}/$id', data: shift.toJson());
    } catch (e) {
      throw Exception('Failed to update shift: $e');
    }
  }

  // 4. Delete Shift
  Future<void> deleteShift(int id) async {
    try {
      await _dio.delete('${ApiConfig.shifts}/$id');
    } catch (e) {
      throw Exception('Failed to delete shift: $e');
    }
  }
}
