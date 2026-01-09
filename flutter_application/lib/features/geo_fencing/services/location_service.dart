import 'package:dio/dio.dart';
import '../../../../shared/services/api_config.dart';
import '../models/location_model.dart';

class LocationService {
  final Dio _dio;

  LocationService(this._dio);

  // 1. Get All Work Locations
  Future<List<WorkLocation>> getLocations() async {
    try {
      final response = await _dio.get(ApiConfig.locations);
      if (response.statusCode == 200 && response.data['ok']) {
        final List<dynamic> list = response.data['locations'];
        return list.map((j) => WorkLocation.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      // Return empty list on error instead of throwing to prevent initial crash, or rethrow? 
      // The snippet rethrows. I'll stick to snippet logic but maybe logging.
      throw Exception('Failed to load locations: $e');
    }
  }

  // 2. Create Location
  Future<void> createLocation(Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiConfig.locations, data: data);
    } catch (e) {
      throw Exception('Failed to create location: $e');
    }
  }

  // 3. Update Location (e.g. radius or active status)
  Future<void> updateLocation(int id, Map<String, dynamic> updates) async {
    try {
      await _dio.put('${ApiConfig.locations}/$id', data: updates);
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }
  
  // 3.1 Delete Location
  Future<void> deleteLocation(int id) async {
    try {
      final response = await _dio.delete('${ApiConfig.locations}/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        // Check for logical failure in 200 OK
        if (data is Map && (data['ok'] == false || data['success'] == false)) {
           throw Exception(data['msg'] ?? data['message'] ?? 'Server could not delete location');
        }
      }
    } catch (e) {
      // Re-throw to let UI handle it
      throw Exception('Failed to delete location: $e');
    }
  }

  // 4. Assign User to Location
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
      await _dio.post(ApiConfig.assignments, data: payload);
    } catch (e) {
        throw Exception('Failed to update assignment: $e');
    }
  }

  // 5. Get Users with Work Locations
  Future<List<Map<String, dynamic>>> getUsersWithLocations() async {
    try {
      final response = await _dio.get(ApiConfig.adminUsers, queryParameters: {'workLocation': 'true'});
      if (response.statusCode == 200 && (response.data['success'] == true || response.data['ok'] == true)) {
         // Handle both 'success' (React style) and 'ok' (common)
         final List<dynamic> list = response.data['users'];
         return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // 6. Reverse Geocode (OpenStreetMap Nominatim)
  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      // Use a clean Dio instance or the existing one?
      // Existing one might have base URL set to API.
      // We need to override base URL or use full URL.
      // If we pass full URL to dio.get(), it usually overrides base url depending on version, 
      // but Nominatim doesn't use our Auth headers.
      // Better to use a fresh Dio instance to avoid sending our App Auth tokens to OSM (privacy/security).
      final dio = Dio(); 
      final response = await dio.get(ApiConfig.nominatimUrl, queryParameters: {
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
