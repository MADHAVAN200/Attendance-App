import 'package:dio/dio.dart';
import '../models/shift_model.dart';
import '../../../shared/constants/api_constants.dart';

class ShiftService {
  final Dio _dio;

  ShiftService(this._dio);

  // 1. Get All Shifts
  Future<List<Shift>> getShifts() async {
    try {
      final response = await _dio.get(ApiConstants.policyShifts);
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
      await _dio.post(ApiConstants.policyShifts, data: shift.toJson());
    } catch (e) {
      throw Exception('Failed to create shift: $e');
    }
  }

  // 3. Update Shift
  Future<void> updateShift(int id, Shift shift) async {
    try {
      await _dio.put('${ApiConstants.policyShifts}/$id', data: shift.toJson());
    } catch (e) {
      throw Exception('Failed to update shift: $e');
    }
  }

  // 4. Delete Shift
  Future<void> deleteShift(int id) async {
    try {
      await _dio.delete('${ApiConstants.policyShifts}/$id');
    } catch (e) {
      throw Exception('Failed to delete shift: $e');
    }
  }
}
