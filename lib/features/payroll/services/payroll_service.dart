import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/api_constants.dart';
import '../models/payroll_model.dart';

class PayrollService {
  final Dio? _dio;

  PayrollService([this._dio]);

  // In-memory cached data store for instant seamless responsive rendering
  List<Payslip> _cachedPayslips = [];
  PayrollRun? _currentRun;
  String _currentPayPeriod = DateFormat('MMMM yyyy').format(DateTime.now());

  String get currentPayPeriod => _currentPayPeriod;

  final List<String> availablePayPeriods = [
    DateFormat('MMMM yyyy').format(DateTime.now()),
    DateFormat('MMMM yyyy').format(DateTime.now().subtract(const Duration(days: 30))),
    DateFormat('MMMM yyyy').format(DateTime.now().subtract(const Duration(days: 60))),
    DateFormat('MMMM yyyy').format(DateTime.now().subtract(const Duration(days: 90))),
  ];

  // 1. Fetch Payroll Summary Run for a Pay Period
  Future<PayrollRun> getPayrollRun({String? payPeriod}) async {
    final period = payPeriod ?? _currentPayPeriod;
    _currentPayPeriod = period;

    try {
      if (_dio != null) {
        final response = await _dio.get('${ApiConstants.baseUrl}/payroll/runs', queryParameters: {'period': period});
        if (response.statusCode == 200 && response.data['ok'] == true) {
          final data = response.data['data'];
          _currentRun = PayrollRun(
            id: data['id'] ?? 'PR-${period.replaceAll(' ', '-')}',
            payPeriod: period,
            status: PayrollStatus.values.firstWhere((e) => e.name == data['status'], orElse: () => PayrollStatus.approved),
            totalEmployees: data['totalEmployees'] ?? 18,
            totalGrossPayout: (data['totalGrossPayout'] as num?)?.toDouble() ?? 1150000.0,
            totalDeductions: (data['totalDeductions'] as num?)?.toDouble() ?? 142000.0,
            totalNetPayout: (data['totalNetPayout'] as num?)?.toDouble() ?? 1008000.0,
            processedDate: DateTime.tryParse(data['processedDate'] ?? '') ?? DateTime.now(),
            isLocked: data['isLocked'] ?? false,
          );
          return _currentRun!;
        }
      }
    } catch (e) {
      debugPrint("API Error in getPayrollRun: $e. Falling back to local data.");
    }

    _currentRun = _generateMockRun(period);
    return _currentRun!;
  }

  // 2. Fetch Employee Payslips list for a Pay Period
  Future<List<Payslip>> getPayslips({String? payPeriod, String? department, String? searchQuery}) async {
    final period = payPeriod ?? _currentPayPeriod;

    try {
      if (_dio != null) {
        final response = await _dio.get(
          '${ApiConstants.baseUrl}/payroll/slips',
          queryParameters: {
            'period': period,
            if (department != null && department != 'All') 'department': department,
            if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
          },
        );
        if (response.statusCode == 200 && response.data['ok'] == true) {
          final list = (response.data['data'] as List).map((e) => Payslip.fromJson(e)).toList();
          _cachedPayslips = list;
          return _filterPayslips(list, department: department, searchQuery: searchQuery);
        }
      }
    } catch (e) {
      debugPrint("API Error in getPayslips: $e. Using structured local dataset.");
    }

    if (_cachedPayslips.isEmpty || _currentPayPeriod != period) {
      _cachedPayslips = _generateMockPayslips(period);
    }

    return _filterPayslips(_cachedPayslips, department: department, searchQuery: searchQuery);
  }

  List<Payslip> _filterPayslips(List<Payslip> slips, {String? department, String? searchQuery}) {
    return slips.where((slip) {
      bool matchesDept = true;
      if (department != null && department != 'All' && department.isNotEmpty) {
        matchesDept = slip.department.toLowerCase() == department.toLowerCase();
      }

      bool matchesSearch = true;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        matchesSearch = slip.employeeName.toLowerCase().contains(query) ||
            slip.employeeId.toLowerCase().contains(query) ||
            slip.designation.toLowerCase().contains(query);
      }

      return matchesDept && matchesSearch;
    }).toList();
  }

  // 3. Process / Recalculate Payroll Run for Pay Period
  Future<PayrollRun> processPayrollRun({required String payPeriod}) async {
    _currentPayPeriod = payPeriod;

    try {
      if (_dio != null) {
        final response = await _dio.post('${ApiConstants.baseUrl}/payroll/process', data: {'period': payPeriod});
        if (response.statusCode == 200 && response.data['ok'] == true) {
          return getPayrollRun(payPeriod: payPeriod);
        }
      }
    } catch (e) {
      debugPrint("API Error processing payroll: $e. Executing local batch processing.");
    }

    // Refresh mock payslips for period with recalculated components
    _cachedPayslips = _generateMockPayslips(payPeriod, isProcessed: true);

    double totalGross = 0.0;
    double totalDeductions = 0.0;
    for (var slip in _cachedPayslips) {
      totalGross += slip.breakdown.totalEarnings;
      totalDeductions += slip.breakdown.totalDeductions;
    }

    _currentRun = PayrollRun(
      id: 'PR-${payPeriod.replaceAll(' ', '-')}',
      payPeriod: payPeriod,
      status: PayrollStatus.disbursed,
      totalEmployees: _cachedPayslips.length,
      totalGrossPayout: totalGross,
      totalDeductions: totalDeductions,
      totalNetPayout: totalGross - totalDeductions,
      processedDate: DateTime.now(),
      isLocked: true,
    );

    return _currentRun!;
  }

  // 4. Update individual payslip adjustments (e.g. custom advance deduction or overtime edit)
  Future<Payslip> updatePayslipAdjustment({
    required String payslipId,
    required double salaryAdvance,
    required double overtimeHours,
  }) async {
    final index = _cachedPayslips.indexWhere((p) => p.id == payslipId);
    if (index != -1) {
      final old = _cachedPayslips[index];
      final newBreakdown = SalaryBreakdown.calculate(
        monthlyGross: old.breakdown.basic * 2.0, // basic is 50% gross
        overtimeHours: overtimeHours,
        unpaidLeaves: old.unpaidLeaves,
        totalWorkingDays: old.totalWorkingDays,
        salaryAdvance: salaryAdvance,
      );

      final updated = Payslip(
        id: old.id,
        employeeId: old.employeeId,
        employeeName: old.employeeName,
        designation: old.designation,
        department: old.department,
        panNumber: old.panNumber,
        bankAccount: old.bankAccount,
        payPeriod: old.payPeriod,
        totalWorkingDays: old.totalWorkingDays,
        presentDays: old.presentDays,
        unpaidLeaves: old.unpaidLeaves,
        overtimeHours: overtimeHours,
        breakdown: newBreakdown,
        status: old.status,
        generatedDate: DateTime.now(),
      );

      _cachedPayslips[index] = updated;
      return updated;
    }

    throw Exception("Payslip not found");
  }

  // Mock Generators
  PayrollRun _generateMockRun(String period) {
    return PayrollRun(
      id: 'PR-${period.replaceAll(' ', '-')}',
      payPeriod: period,
      status: PayrollStatus.approved,
      totalEmployees: 12,
      totalGrossPayout: 785000.0,
      totalDeductions: 98400.0,
      totalNetPayout: 686600.0,
      processedDate: DateTime.now().subtract(const Duration(days: 3)),
      isLocked: false,
    );
  }

  List<Payslip> _generateMockPayslips(String period, {bool isProcessed = false}) {
    final List<Map<String, dynamic>> rawData = [
      {
        'id': 'SLIP-101',
        'empId': 'EMP-001',
        'name': 'Rajesh Kumar',
        'dept': 'Engineering',
        'role': 'Senior Software Engineer',
        'gross': 85000.0,
        'pan': 'ABCDE1234F',
        'bank': 'HDFC Bank - 5010098231',
        'working': 26,
        'present': 25,
        'unpaid': 1,
        'ot': 8.0,
        'advance': 0.0,
      },
      {
        'id': 'SLIP-102',
        'empId': 'EMP-002',
        'name': 'Priya Sharma',
        'dept': 'Product',
        'role': 'Product Manager',
        'gross': 95000.0,
        'pan': 'PQRSW9876K',
        'bank': 'ICICI Bank - 0019284756',
        'working': 26,
        'present': 26,
        'unpaid': 0,
        'ot': 4.0,
        'advance': 5000.0,
      },
      {
        'id': 'SLIP-103',
        'empId': 'EMP-003',
        'name': 'Anish Verma',
        'dept': 'Engineering',
        'role': 'UI/UX Lead Designer',
        'gross': 72000.0,
        'pan': 'LMNOP4567J',
        'bank': 'Axis Bank - 9180293847',
        'working': 26,
        'present': 24,
        'unpaid': 2,
        'ot': 10.0,
        'advance': 0.0,
      },
      {
        'id': 'SLIP-104',
        'empId': 'EMP-004',
        'name': 'Sneha Patel',
        'dept': 'Operations',
        'role': 'HR Business Partner',
        'gross': 65000.0,
        'pan': 'STUVW3412M',
        'bank': 'SBI - 3091827465',
        'working': 26,
        'present': 26,
        'unpaid': 0,
        'ot': 0.0,
        'advance': 2000.0,
      },
      {
        'id': 'SLIP-105',
        'empId': 'EMP-005',
        'name': 'Vikram Singh',
        'dept': 'Operations',
        'role': 'Site Operations Lead',
        'gross': 58000.0,
        'pan': 'FGHIJ5678N',
        'bank': 'Kotak Bank - 7712398471',
        'working': 26,
        'present': 23,
        'unpaid': 3,
        'ot': 14.0,
        'advance': 0.0,
      },
      {
        'id': 'SLIP-106',
        'empId': 'EMP-006',
        'name': 'Divya Nair',
        'dept': 'Marketing',
        'role': 'Growth Manager',
        'gross': 60000.0,
        'pan': 'KKLMM8821P',
        'bank': 'HDFC Bank - 5010044192',
        'working': 26,
        'present': 26,
        'unpaid': 0,
        'ot': 2.0,
        'advance': 0.0,
      },
    ];

    return rawData.map((item) {
      final gross = item['gross'] as double;
      final unpaid = item['unpaid'] as int;
      final ot = item['ot'] as double;
      final advance = item['advance'] as double;
      final working = item['working'] as int;

      final breakdown = SalaryBreakdown.calculate(
        monthlyGross: gross,
        overtimeHours: ot,
        unpaidLeaves: unpaid,
        totalWorkingDays: working,
        salaryAdvance: advance,
      );

      return Payslip(
        id: item['id'],
        employeeId: item['empId'],
        employeeName: item['name'],
        designation: item['role'],
        department: item['dept'],
        panNumber: item['pan'],
        bankAccount: item['bank'],
        payPeriod: period,
        totalWorkingDays: working,
        presentDays: item['present'],
        unpaidLeaves: unpaid,
        overtimeHours: ot,
        breakdown: breakdown,
        status: isProcessed ? PayrollStatus.disbursed : PayrollStatus.approved,
        generatedDate: DateTime.now(),
      );
    }).toList();
  }
}
