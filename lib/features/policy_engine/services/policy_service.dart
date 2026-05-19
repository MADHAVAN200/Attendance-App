import 'package:dio/dio.dart';
import '../../../shared/constants/api_constants.dart';

class PolicyService {
  final Dio _dio;

  PolicyService(this._dio);

  // 1. Get Policy Config
  Future<Map<String, dynamic>> getPolicyConfig() async {
    try {
      final response = await _dio.get(ApiConstants.policyConfig);
      if (response.statusCode == 200 && response.data['success']) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw Exception('Failed to load policy config: $e');
    }
  }

  // 2. Get Automation Policies
  Future<List<dynamic>> getAutomationPolicies() async {
    try {
      final response = await _dio.get(ApiConstants.policyAutomation);
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['policies'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load automation policies: $e');
    }
  }

  // 3. Create Automation Policy
  Future<void> createAutomationPolicy(Map<String, dynamic> policyData) async {
    try {
      await _dio.post(ApiConstants.policyAutomation, data: policyData);
    } catch (e) {
      throw Exception('Failed to create automation policy: $e');
    }
  }
}
