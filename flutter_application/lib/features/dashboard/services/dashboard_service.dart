import 'package:dio/dio.dart';
import '../../../shared/constants/api_constants.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/models/dashboard_model.dart';

class DashboardService {
  final AuthService _authService;

  DashboardService(this._authService);

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
      rethrow;
    }
  }
}
