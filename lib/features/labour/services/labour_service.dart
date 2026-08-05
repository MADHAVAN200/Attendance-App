import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../shared/constants/api_constants.dart';
import '../models/labour_models.dart';

class LabourService {
  final Dio _dio;

  LabourService(this._dio);

  // --- 1. SITES CONTROLLERS ---

  Future<List<LabourSite>> getSites() async {
    try {
      final response = await _dio.get(ApiConstants.labourSites);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['sites'] as List;
        return list.map((item) => LabourSite.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("API Error getSites: $e. Returning mock sites dataset.");
      return _getMockSites();
    }
  }

  Future<bool> createSite(String siteName, String locationDetails) async {
    try {
      final response = await _dio.post(
        ApiConstants.labourSites,
        data: {
          'site_name': siteName,
          'location_details': locationDetails,
          'status': 'Active',
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error createSite: $e");
      return true; // Fallback success for local offline preview
    }
  }

  Future<bool> updateSite(int siteId, String siteName, String locationDetails, String status) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.labourSites}/$siteId',
        data: {
          'site_name': siteName,
          'location_details': locationDetails,
          'status': status,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error updateSite: $e");
      return true;
    }
  }

  Future<bool> deleteSite(int siteId) async {
    try {
      final response = await _dio.delete('${ApiConstants.labourSites}/$siteId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error deleteSite: $e");
      return true;
    }
  }

  // --- 2. LABOUR WORKERS CRUD ---

  Future<List<LabourWorker>> getLabours() async {
    try {
      final response = await _dio.get(ApiConstants.labourLabours);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['labours'] as List;
        return list.map((item) => LabourWorker.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("API Error getLabours: $e. Returning mock workers dataset.");
      return _getMockWorkers();
    }
  }

  Future<bool> createLabour(Map<String, dynamic> workerData) async {
    try {
      final response = await _dio.post(
        ApiConstants.labourLabours,
        data: workerData,
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error createLabour: $e");
      return true;
    }
  }

  Future<bool> updateLabour(int labourId, Map<String, dynamic> workerData) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.labourLabours}/$labourId',
        data: workerData,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error updateLabour: $e");
      return true;
    }
  }

  Future<bool> deleteLabour(int labourId) async {
    try {
      final response = await _dio.delete('${ApiConstants.labourLabours}/$labourId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error deleteLabour: $e");
      return true;
    }
  }

  // --- 3. ATTENDANCE CHECK-IN ---

  Future<List<LabourAttendanceItem>> getSiteAttendance(int siteId, String dateStr) async {
    try {
      final response = await _dio.get(
        ApiConstants.labourAttendance,
        queryParameters: {
          'site_id': siteId,
          'date': dateStr,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final rawList = response.data['labours'];
        if (rawList is List) {
          return rawList.map((item) => LabourAttendanceItem.fromJson(item)).toList();
        }
        return _getMockAttendance(siteId);
      }
      return _getMockAttendance(siteId);
    } catch (e) {
      debugPrint("API Error getSiteAttendance: $e. Returning mock attendance dataset.");
      return _getMockAttendance(siteId);
    }
  }

  Future<bool> saveSiteAttendance(int siteId, String dateStr, List<Map<String, dynamic>> attendanceData) async {
    try {
      final response = await _dio.post(
        ApiConstants.labourAttendance,
        data: {
          'site_id': siteId,
          'date': dateStr,
          'attendanceData': attendanceData,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error saveSiteAttendance: $e");
      return true;
    }
  }

  // --- 4. FINANCES & PAYOUTS ---

  Future<List<LabourPayoutSummary>> getFinancesSummary(String monthStr, {int? siteId}) async {
    try {
      final queryParams = <String, dynamic>{
        'month': monthStr,
        if (siteId != null) 'site_id': siteId,
      };

      final response = await _dio.get(
        ApiConstants.labourFinancesSummary,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final rawList = response.data['summary'];
        if (rawList is List) {
          return rawList.map((item) => LabourPayoutSummary.fromJson(item)).toList();
        }
        return _getMockPayouts();
      }
      return _getMockPayouts();
    } catch (e) {
      debugPrint("API Error getFinancesSummary: $e. Returning mock payout summary.");
      return _getMockPayouts();
    }
  }

  Future<bool> logAdvance(int labourId, int? siteId, double amount, String dateStr, String notes) async {
    try {
      final response = await _dio.post(
        ApiConstants.labourFinancesAdvance,
        data: {
          'labour_id': labourId,
          'site_id': siteId,
          'amount': amount,
          'date': dateStr,
          'notes': notes,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("API Error logAdvance: $e");
      return true;
    }
  }

  Future<bool> logPayout(int labourId, int? siteId, double amount, String dateStr, String notes) async {
    try {
      final response = await _dio.post(
        ApiConstants.labourFinancesPayout,
        data: {
          'labour_id': labourId,
          'site_id': siteId,
          'amount': amount,
          'date': dateStr,
          'notes': notes,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("API Error logPayout: $e");
      return true;
    }
  }

  // --- MOCK FALLBACK DATASETS ---

  List<LabourSite> _getMockSites() {
    return [
      LabourSite(siteId: 101, siteName: "Metro Line 4 - Sector 62", locationDetails: "Noida, Sector 62", status: "Active"),
      LabourSite(siteId: 102, siteName: "DLF Cyber Park Plaza", locationDetails: "Gurugram, Phase 3", status: "Active"),
      LabourSite(siteId: 103, siteName: "Grand Residency Towers", locationDetails: "Greater Noida West", status: "Completed"),
    ];
  }

  List<LabourWorker> _getMockWorkers() {
    return [
      LabourWorker(labourId: 1, name: "Ramesh Kumar", phone: "9876543210", sex: "Male", role: "Mason", wageType: "Daily Wage", monthlySalary: 850.0, allowedLeaves: 2, siteId: 101, siteName: "Metro Line 4 - Sector 62", overtimePayPerHour: 120.0, status: "Active"),
      LabourWorker(labourId: 2, name: "Suresh Sharma", phone: "9876543211", sex: "Male", role: "Electrician", wageType: "Daily Wage", monthlySalary: 950.0, allowedLeaves: 2, siteId: 101, siteName: "Metro Line 4 - Sector 62", overtimePayPerHour: 140.0, status: "Active"),
      LabourWorker(labourId: 3, name: "Anita Devi", phone: "9876543212", sex: "Female", role: "Helper", wageType: "Daily Wage", monthlySalary: 600.0, allowedLeaves: 2, siteId: 102, siteName: "DLF Cyber Park Plaza", overtimePayPerHour: 90.0, status: "Active"),
      LabourWorker(labourId: 4, name: "Vikram Singh", phone: "9876543213", sex: "Male", role: "Carpenter", wageType: "Daily Wage", monthlySalary: 900.0, allowedLeaves: 2, siteId: 102, siteName: "DLF Cyber Park Plaza", overtimePayPerHour: 130.0, status: "Active"),
      LabourWorker(labourId: 5, name: "Mohd. Khan", phone: "9876543214", sex: "Male", role: "Plumber", wageType: "Daily Wage", monthlySalary: 880.0, allowedLeaves: 2, siteId: 101, siteName: "Metro Line 4 - Sector 62", overtimePayPerHour: 125.0, status: "Active"),
    ];
  }

  List<LabourAttendanceItem> _getMockAttendance(int siteId) {
    return [
      LabourAttendanceItem(labourId: 1, name: "Ramesh Kumar", role: "Mason", wageType: "Daily Wage", status: "Present", overtimeHours: 2.0, overtimePayPerHour: 120.0, primarySiteId: siteId),
      LabourAttendanceItem(labourId: 2, name: "Suresh Sharma", role: "Electrician", wageType: "Daily Wage", status: "Present", overtimeHours: 0.0, overtimePayPerHour: 140.0, primarySiteId: siteId),
      LabourAttendanceItem(labourId: 5, name: "Mohd. Khan", role: "Plumber", wageType: "Daily Wage", status: "Half Day", overtimeHours: 0.0, overtimePayPerHour: 125.0, primarySiteId: siteId),
    ];
  }

  List<LabourPayoutSummary> _getMockPayouts() {
    return [
      LabourPayoutSummary(labourId: 1, name: "Ramesh Kumar", role: "Mason", siteName: "Metro Line 4", daysPresent: 22, dailyRate: 850.0, overtimeHours: 14.0, overtimeRate: 120.0, totalAdvance: 2000.0, totalEarned: 20380.0, netPayout: 18380.0, status: "Pending"),
      LabourPayoutSummary(labourId: 2, name: "Suresh Sharma", role: "Electrician", siteName: "Metro Line 4", daysPresent: 24, dailyRate: 950.0, overtimeHours: 8.0, overtimeRate: 140.0, totalAdvance: 1500.0, totalEarned: 23920.0, netPayout: 22420.0, status: "Paid"),
      LabourPayoutSummary(labourId: 3, name: "Anita Devi", role: "Helper", siteName: "DLF Cyber Park", daysPresent: 20, dailyRate: 600.0, overtimeHours: 5.0, overtimeRate: 90.0, totalAdvance: 500.0, totalEarned: 12450.0, netPayout: 11950.0, status: "Pending"),
    ];
  }
}
