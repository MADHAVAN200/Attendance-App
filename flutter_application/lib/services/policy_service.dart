import 'api_client.dart';
import '../shared/models/holiday_model.dart';
import '../shared/models/shift_model.dart';

class PolicyService {
  final ApiClient _client = ApiClient();

  // --- Holidays ---
  Future<List<Holiday>> getHolidays() async {
    try {
      final response = await _client.get('/holiday');
      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => Holiday.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching holidays: $e");
    }
    return [];
  }

  Future<void> createHoliday(Map<String, dynamic> holidayData) async {
    // Wrap in "holidays" list if API expects bulk format or single
    // Postman shows both "Create Holiday (Single)" and "Bulk"
    // Single: Body = JSON object
    await _client.post('/holiday', data: holidayData);
  }

  Future<void> createHolidaysBulk(List<dynamic> holidays) async {
    await _client.post('/holiday', data: {"holidays": holidays});
  }

  Future<void> updateHoliday(int id, Map<String, dynamic> data) async {
    await _client.put('/holiday/$id', data: data);
  }

  Future<void> deleteHolidays(List<int> ids) async {
    await _client.delete('/holiday', data: {"ids": ids});
  }

  // --- Shifts ---
  Future<List<Shift>> getAllShifts() async {
    try {
      final response = await _client.get('/policies/shifts');
      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => Shift.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching policy shifts: $e");
    }
    return [];
  }

  Future<void> createShift(Map<String, dynamic> shiftData) async {
    await _client.post('/policies/shifts', data: shiftData);
  }

  Future<void> updateShift(int shiftId, Map<String, dynamic> shiftData) async {
    await _client.put('/policies/shifts/$shiftId', data: shiftData);
  }

  Future<void> deleteShift(int shiftId) async {
    await _client.delete('/policies/shifts/$shiftId');
  }

  // --- config ---
  Future<Map<String, dynamic>?> getPolicyConfig() async {
    try {
      final response = await _client.get('/policies/config');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching policy config: $e");
    }
    return null;
  }
}
