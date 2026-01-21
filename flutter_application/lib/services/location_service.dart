import 'package:dio/dio.dart';
import 'api_client.dart';
import '../shared/models/location_model.dart';
// import '../shared/constants/api_constants.dart';

class LocationService {
  final ApiClient _client = ApiClient();

  // Get All Locations (Admin)
  Future<List<WorkLocation>> getAllLocations() async {
    try {
      final response = await _client.get('/locations');
      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => WorkLocation.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching locations: $e");
      rethrow;
    }
    return [];
  }

  // Alias for legacy consumer compatibility
  Future<List<WorkLocation>> getLocations() => getAllLocations();

  // Create Location
  Future<void> createLocation(Map<String, dynamic> data) async {
    await _client.post('/locations', data: data);
  }

  // Update Location
  Future<void> updateLocation(int id, Map<String, dynamic> data) async {
    await _client.put('/locations/$id', data: data);
  }

  // Delete Location
  Future<void> deleteLocation(int id) async {
    await _client.delete('/locations/$id');
  }

  // Update Assignments
  Future<void> updateAssignments(Map<String, dynamic> data) async {
    await _client.post('/locations/assignments', data: data);
  }

  // Get My Data locations (Employee)
  Future<List<dynamic>> getMyLocations() async {
    try {
      final response = await _client.get('/employee/locations');
      if (response.statusCode == 200 && response.data['ok']) {
        return response.data['data'];
      }
    } catch (e) {
      print("Error fetching my locations: $e");
    }
    return [];
  }

  // --- Assignments ---
  Future<void> assignUser(int locationId, int userId, bool isAdding) async {
    try {
      final payload = {
        "assignments": [
          {
            "work_location_id": locationId,
            "add": isAdding ? [userId] : [],
            "remove": isAdding ? [] : [userId]
          }
        ]
      };
      await _client.post('/locations/assignments', data: payload);
    } catch (e) {
      print("Error assigning user: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getUsersWithLocations() async {
    try {
      final response = await _client.get('/admin/users', queryParameters: {'workLocation': 'true'});
      if (response.statusCode == 200 && response.data['ok']) {
         return response.data['data'];
      }
      return [];
    } catch (e) {
      print("Error fetching users with locations: $e");
      rethrow;
    }
  }

  // --- Utils ---
  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      // Use fresh Dio for external API to avoid Auth headers
      final dio = Dio(); 
      final response = await dio.get('https://nominatim.openstreetmap.org/reverse', queryParameters: {
        'format': 'json',
        'lat': lat,
        'lon': lng
      });
      
      if (response.statusCode == 200) {
        return response.data['display_name'] ?? '';
      }
      return '';
    } catch (e) {
      print("Geocoding failed: $e");
      return '';
    }
  }
}
