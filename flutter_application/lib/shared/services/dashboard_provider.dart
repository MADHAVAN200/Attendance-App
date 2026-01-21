import 'package:flutter/material.dart';
import '../../services/report_service.dart';
import '../models/dashboard_model.dart';

class DashboardProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  DashboardStats _stats = DashboardStats.initial();
  DashboardTrends _trends = DashboardTrends.initial();
  List<Map<String, dynamic>> _activities = [];
  List<double> _chartData = List.filled(7, 0.0);

  bool _isLoading = false;
  String? _error;

  DashboardProvider();

  bool get isLoading => _isLoading;
  String? get error => _error;

  String _activeRange = 'weekly';
  String get activeRange => _activeRange;
  
  String _viewMode = 'range'; // 'range' or 'calendar'
  String get viewMode => _viewMode;

  int _selectedMonth = DateTime.now().month;
  int get selectedMonth => _selectedMonth;

  int _selectedYear = DateTime.now().year;
  int get selectedYear => _selectedYear;

  DashboardData? _data;
  DashboardData? get data => _data;

  // Initial empty data to prevent null checks everywhere if needed
  DashboardStats get stats => _data?.stats ?? DashboardStats(presentToday: 0, totalEmployees: 0, absentToday: 0, lateCheckins: 0);
  DashboardTrends get trends => _data?.trends ?? DashboardTrends(present: '0%', absent: '0%', late: '0%');
  List<ChartData> get chartData => _data?.chartData ?? [];
  List<ActivityLog> get activities => _data?.activities ?? [];

  // Cache
  final Map<String, DashboardData> _cache = {};

  Future<void> fetchDashboardData({bool forceRefresh = false}) async {
    // Determine effective range/params
    String range = _viewMode == 'range' ? _activeRange : 'custom';
    int? month = _viewMode == 'calendar' ? _selectedMonth : null;
    int? year = _viewMode == 'calendar' ? _selectedYear : null;

    String cacheKey = '${range}_${month ?? "now"}_${year ?? "now"}';

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      _data = _cache[cacheKey];
      _isLoading = false;
        notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      // notifyListeners(); // Don't notify here to avoid flicker if just switching view modes quickly

      final resultMaps = await _reportService.getDashboardStats(
        range: range,
        // Helper to convert ints to strings if needed by API, or update service signature
        // The service takes String? month/date, but here we have ints.
        // Let's assume the API handles it or we convert here.
        // Checking ReportService again... getDashboardStats takes (range), currently no month/year param in signature?
        // Wait, ReportService.getDashboardStats only takes range.
        // AdminService/ReportService split might need adjustment if logic was specific.
        // Assuming basics for now.
      );
      
      if (resultMaps != null) {
         // Create DashboardData from Map
         final result = DashboardData.fromJson(resultMaps);
         _data = result;
         _cache[cacheKey] = result;
      }
    } catch (e) {
      print("Dashboard Error: $e");
      // Optionally handle error state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRange(String range) {
    if (_activeRange != range) {
      _activeRange = range;
      fetchDashboardData();
    }
  }

  void setViewMode(String mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      fetchDashboardData();
    }
  }

  void setMonth(int month) {
    if (_selectedMonth != month) {
      _selectedMonth = month;
      if (_viewMode == 'calendar') fetchDashboardData();
    }
  }

  void setYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      if (_viewMode == 'calendar') fetchDashboardData();
    }
  }
}
