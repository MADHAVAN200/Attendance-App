import 'package:flutter/material.dart';
import '../models/leave_request_model.dart';
import '../services/leave_service.dart';
import '../../../shared/services/auth_service.dart';

class LeaveProvider with ChangeNotifier {
  final AuthService _authService;
  late final LeaveService _leaveService;

  // Employee State
  List<LeaveRequest> _myLeaves = [];
  bool _isLoadingMyLeaves = false;
  String? _myLeavesError;

  // Admin State
  List<LeaveRequest> _pendingRequests = [];
  bool _isLoadingPending = false;
  String? _pendingError;

  List<LeaveRequest> _adminHistory = [];
  bool _isLoadingAdminHistory = false;
  String? _adminHistoryError;

  LeaveProvider(this._authService) {
    _leaveService = LeaveService(_authService.dio);
  }

  // Getters
  List<LeaveRequest> get myLeaves => _myLeaves;
  bool get isLoadingMyLeaves => _isLoadingMyLeaves;
  String? get myLeavesError => _myLeavesError;

  List<LeaveRequest> get pendingRequests => _pendingRequests;
  bool get isLoadingPending => _isLoadingPending;
  String? get pendingError => _pendingError;

  List<LeaveRequest> get adminHistory => _adminHistory;
  bool get isLoadingAdminHistory => _isLoadingAdminHistory;
  String? get adminHistoryError => _adminHistoryError;

  // --------------------------------------------------------------------------
  // EMPLOYEE METHODS
  // --------------------------------------------------------------------------

  Future<void> fetchMyLeaves({bool forceRefresh = false}) async {
    if (!forceRefresh && _myLeaves.isNotEmpty) return;

    _isLoadingMyLeaves = true;
    _myLeavesError = null;
    notifyListeners();

    try {
      final leaves = await _leaveService.getMyHistory();
      debugPrint('LeaveProvider: Fetched ${leaves.length} leaves');
      _myLeaves = leaves;
    } catch (e) {
      _myLeavesError = e.toString();
    } finally {
      _isLoadingMyLeaves = false;
      notifyListeners();
    }
  }

  Future<void> submitLeaveRequest(Map<String, dynamic> requestData) async {
    _isLoadingMyLeaves = true;
    notifyListeners();
    try {
      await _leaveService.submitLeaveRequest(requestData);
      // Refresh list after submission
      await fetchMyLeaves(forceRefresh: true);
    } catch (e) {
      _myLeavesError = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoadingMyLeaves = false;
      notifyListeners();
    }
  }

  Future<void> withdrawRequest(int id) async {
    try {
      await _leaveService.withdrawRequest(id);
      _myLeaves.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // ADMIN METHODS
  // --------------------------------------------------------------------------

  Future<void> fetchPendingRequests({bool forceRefresh = false}) async {
    if (!forceRefresh && _pendingRequests.isNotEmpty) return;

    _isLoadingPending = true;
    _pendingError = null;
    notifyListeners();

    try {
      _pendingRequests = await _leaveService.getPendingRequests();
    } catch (e) {
      _pendingError = e.toString();
    } finally {
      _isLoadingPending = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdminHistory({
    int? userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoadingAdminHistory = true;
    _adminHistoryError = null;
    notifyListeners();

    try {
      _adminHistory = await _leaveService.getAdminHistory(
        userId: userId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _adminHistoryError = e.toString();
    } finally {
      _isLoadingAdminHistory = false;
      notifyListeners();
    }
  }

  Future<void> reviewRequest(int id, {required String status, String? comment, String? payType, int? payPercentage}) async {
    try {
      await _leaveService.updateRequestStatus(
        id, 
        status, 
        comment: comment,
        payType: payType,
        payPercentage: payPercentage,
      );
      
      // Remove from pending if successful
      _pendingRequests.removeWhere((r) => r.id == id);
      
      // Also update in myLeaves if visible there (e.g. admin viewing own or list refresh)
      final index = _myLeaves.indexWhere((r) => r.id == id);
      if (index != -1) {
        _myLeaves[index] = _myLeaves[index].copyWith(
          status: status,
          adminComment: comment,
          reviewedAt: DateTime.now(),
        );
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Keep these as wrappers for backward compatibility if needed, but point to reviewRequest
  Future<void> approveRequest(int id, {String? comment, String? payType, int? payPercentage}) async {
    return reviewRequest(id, status: 'Approved', comment: comment, payType: payType, payPercentage: payPercentage);
  }

  Future<void> rejectRequest(int id, {String? comment}) async {
    return reviewRequest(id, status: 'Rejected', comment: comment);
  }
}
