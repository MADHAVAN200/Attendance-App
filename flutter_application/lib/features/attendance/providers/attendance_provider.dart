import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/services/auth_service.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  final AuthService _authService;
  late final AttendanceService _attendanceService;

  // Cache: "YYYY-MM-DD" -> List<AttendanceRecord>
  final Map<String, List<AttendanceRecord>> _recordsCache = {};
  
  // Current State
  List<AttendanceRecord> _currentRecords = [];
  bool _isLoading = false;
  String? _error;

  AttendanceProvider(this._authService) {
    _attendanceService = AttendanceService(_authService.dio);
  }

  // Getters
  List<AttendanceRecord> get records => _currentRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch Records for a specific date
  Future<void> fetchRecords(DateTime date, {bool forceRefresh = false}) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    _error = null;

    // 1. Return from Cache if available and not forcing refresh
    if (!forceRefresh && _recordsCache.containsKey(dateStr)) {
      _currentRecords = _recordsCache[dateStr]!;
      notifyListeners();
      return;
    }

    // 2. Fetch from API
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _attendanceService.getMyRecords(fromDate: dateStr, toDate: dateStr);
      
      // Update Cache
      _recordsCache[dateStr] = data;
      _currentRecords = data;
      
    } catch (e) {
      _error = e.toString();
      // If error, maybe clear current records or keep old? 
      // Keeping empty to indicate failure/no data found state is safer for now.
      _currentRecords = []; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Invalidate cache for today (e.g. after punching in/out)
  void invalidateCache(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    _recordsCache.remove(dateStr);
    // Note: We don't automatically refetch here, usually the UI will trigger refetch 
    // or we can call fetchRecords(date, forceRefresh: true) immediately.
  }
}
