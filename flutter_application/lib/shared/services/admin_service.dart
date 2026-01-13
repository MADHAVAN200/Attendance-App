import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../shared/services/auth_service.dart';
import '../models/dashboard_model.dart'; // Ensure you import your model

class AdminService {
  final AuthService _authService;

  AdminService(this._authService);

  Future<DashboardData> getDashboardStats({
    String range = 'weekly',
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = {
        'range': range,
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      };

      final response = await _authService.dio.get(
        ApiConstants.dashboardStats,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return DashboardData.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard stats');
      }
    } catch (e) {
      // Return mock data ONLY for development if API fails or backend not ready
      // Remove this in production
      // return _getMockData(); 
      rethrow;
    }
  }
}
