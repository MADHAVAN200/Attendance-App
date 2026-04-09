class LabourSite {
  final int siteId;
  final String siteName;
  final String? locationDetails;
  final String status;
  final String? endDate;
  final int? workerCount;
  final String? createdAt;
  final String? updatedAt;

  LabourSite({
    required this.siteId,
    required this.siteName,
    this.locationDetails,
    required this.status,
    this.endDate,
    this.workerCount,
    this.createdAt,
    this.updatedAt,
  });

  factory LabourSite.fromJson(Map<String, dynamic> json) {
    return LabourSite(
      siteId: json['site_id'] is int
          ? json['site_id']
          : int.tryParse(json['site_id'].toString()) ?? 0,
      siteName: json['site_name']?.toString() ?? 'Unnamed Site',
      locationDetails: json['location_details']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      endDate: json['end_date']?.toString(),
      workerCount: json['worker_count'] != null
          ? int.tryParse(json['worker_count'].toString())
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site_id': siteId,
      'site_name': siteName,
      'location_details': locationDetails,
      'status': status,
      'end_date': endDate,
    };
  }
}

class LabourWorker {
  final int labourId;
  final String name;
  final String? phone;
  final String sex;
  final String role; // e.g. Mason, Carpenter, Electrician, Plumber, Helper, etc.
  final String wageType;
  final double monthlySalary; // Used as Base Daily Wage Rate in UI & backend
  final int allowedLeaves;
  final int? siteId;
  final String siteName;
  final List<int> siteIds;
  final double overtimePayPerHour;
  final String status;
  final String? createdAt;

  LabourWorker({
    required this.labourId,
    required this.name,
    this.phone,
    required this.sex,
    required this.role,
    required this.wageType,
    required this.monthlySalary,
    required this.allowedLeaves,
    this.siteId,
    this.siteName = 'Unassigned',
    this.siteIds = const [],
    required this.overtimePayPerHour,
    required this.status,
    this.createdAt,
  });

  factory LabourWorker.fromJson(Map<String, dynamic> json) {
    List<int> sIds = [];
    if (json['site_ids'] != null) {
      if (json['site_ids'] is List) {
        sIds = (json['site_ids'] as List)
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .where((id) => id > 0)
            .toList();
      } else if (json['site_ids'] is String) {
        sIds = (json['site_ids'] as String)
            .split(',')
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    }

    String siteStr = 'Unassigned';
    if (json['site_name'] != null && json['site_name'].toString().isNotEmpty) {
      siteStr = json['site_name'].toString();
    } else if (json['site_names'] != null && json['site_names'].toString().isNotEmpty) {
      siteStr = json['site_names'].toString();
    }

    return LabourWorker(
      labourId: json['labour_id'] is int
          ? json['labour_id']
          : int.tryParse(json['labour_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Worker',
      phone: json['phone']?.toString(),
      sex: json['sex']?.toString() ?? 'Male',
      role: json['role']?.toString() ?? 'Helper',
      wageType: json['wage_type']?.toString() ?? 'Daily Wage',
      monthlySalary: (json['monthly_salary'] != null)
          ? double.tryParse(json['monthly_salary'].toString()) ?? 0.0
          : 0.0,
      allowedLeaves: (json['allowed_leaves'] != null)
          ? int.tryParse(json['allowed_leaves'].toString()) ?? 0
          : 0,
      siteId: json['site_id'] != null ? int.tryParse(json['site_id'].toString()) : (sIds.isNotEmpty ? sIds.first : null),
      siteName: siteStr,
      siteIds: sIds,
      overtimePayPerHour: (json['overtime_pay_per_hour'] != null)
          ? double.tryParse(json['overtime_pay_per_hour'].toString()) ?? 0.0
          : 0.0,
      status: json['status']?.toString() ?? 'Active',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labour_id': labourId,
      'name': name,
      'phone': phone,
      'sex': sex,
      'role': role,
      'wage_type': wageType,
      'monthly_salary': monthlySalary,
      'allowed_leaves': allowedLeaves,
      'site_id': siteId,
      'overtime_pay_per_hour': overtimePayPerHour,
      'status': status,
    };
  }
}

class LabourAttendanceItem {
  final int labourId;
  final String name;
  final String role;
  final String wageType;
  String status; // Present, Absent, Half Day, Paid Leave, or ''
  bool isBorrowed;
  int frequentCount;
  Map<String, dynamic>? alreadyMarkedAt; // { site_id, site_name, status }
  bool isScheduledMultiSite;
  double overtimePayPerHour;
  double overtimeHours;

  LabourAttendanceItem({
    required this.labourId,
    required this.name,
    required this.role,
    required this.wageType,
    required this.status,
    this.isBorrowed = false,
    this.frequentCount = 0,
    this.alreadyMarkedAt,
    this.isScheduledMultiSite = false,
    required this.overtimePayPerHour,
    this.overtimeHours = 0.0,
  });

  factory LabourAttendanceItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? alreadyMarked;
    if (json['already_marked_at'] != null && json['already_marked_at'] is Map) {
      alreadyMarked = Map<String, dynamic>.from(json['already_marked_at']);
    }

    return LabourAttendanceItem(
      labourId: json['labour_id'] is int
          ? json['labour_id']
          : int.tryParse(json['labour_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Worker',
      role: json['role']?.toString() ?? 'Helper',
      wageType: json['wage_type']?.toString() ?? 'Daily Wage',
      status: json['status']?.toString() ?? '',
      isBorrowed: json['is_borrowed'] == true,
      frequentCount: (json['frequent_count'] != null)
          ? int.tryParse(json['frequent_count'].toString()) ?? 0
          : 0,
      alreadyMarkedAt: alreadyMarked,
      isScheduledMultiSite: json['is_scheduled_multi_site'] == true,
      overtimePayPerHour: (json['overtime_pay_per_hour'] != null)
          ? double.tryParse(json['overtime_pay_per_hour'].toString()) ?? 0.0
          : 0.0,
      overtimeHours: (json['overtime_hours'] != null)
          ? double.tryParse(json['overtime_hours'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labour_id': labourId,
      'status': status,
      'overtime_hours': overtimeHours,
    };
  }
}

class LabourMonthDetails {
  final String start;
  final String end;
  final int totalDays;
  final int elapsedDays;
  final int year;
  final int month;

  LabourMonthDetails({
    required this.start,
    required this.end,
    required this.totalDays,
    required this.elapsedDays,
    required this.year,
    required this.month,
  });

  factory LabourMonthDetails.fromJson(Map<String, dynamic> json) {
    return LabourMonthDetails(
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      totalDays: int.tryParse(json['totalDays']?.toString() ?? '30') ?? 30,
      elapsedDays: int.tryParse(json['elapsedDays']?.toString() ?? '30') ?? 30,
      year: int.tryParse(json['year']?.toString() ?? '${DateTime.now().year}') ?? DateTime.now().year,
      month: int.tryParse(json['month']?.toString() ?? '${DateTime.now().month}') ?? DateTime.now().month,
    );
  }
}

class LabourMonthlyRow {
  final int labourId;
  final String name;
  final String role;
  final String wageType;
  final double monthlySalary;
  final int? primarySiteId;
  /// Map of day string ('1', '2', ... '31') -> status ('P', 'A', 'HD', 'PL', 'WO', 'OT', '')
  final Map<String, String> days;
  final int totalPresent;
  final int totalHalfDays;
  final int totalAbsent;
  final int totalPaidLeaves;
  final double totalOvertimeHours;
  final int totalDaysWorked;

  LabourMonthlyRow({
    required this.labourId,
    required this.name,
    required this.role,
    required this.wageType,
    required this.monthlySalary,
    this.primarySiteId,
    required this.days,
    required this.totalPresent,
    required this.totalHalfDays,
    required this.totalAbsent,
    required this.totalPaidLeaves,
    required this.totalOvertimeHours,
    required this.totalDaysWorked,
  });

  factory LabourMonthlyRow.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as Map<String, dynamic>? ?? {};
    final mappedDays = rawDays.map((k, v) => MapEntry(k, v?.toString() ?? ''));

    final pCount = (json['total_present'] != null)
        ? int.tryParse(json['total_present'].toString()) ?? 0
        : mappedDays.values.where((v) => v == 'P' || v == 'Present' || v == 'OT').length;

    final hCount = (json['total_half_days'] != null)
        ? int.tryParse(json['total_half_days'].toString()) ?? 0
        : mappedDays.values.where((v) => v == 'HD' || v == 'Half Day' || v == 'H').length;

    final aCount = (json['total_absent'] != null)
        ? int.tryParse(json['total_absent'].toString()) ?? 0
        : mappedDays.values.where((v) => v == 'A' || v == 'Absent').length;

    final plCount = (json['total_paid_leaves'] != null)
        ? int.tryParse(json['total_paid_leaves'].toString()) ?? 0
        : mappedDays.values.where((v) => v == 'PL' || v == 'Paid Leave').length;

    final otHours = (json['total_overtime_hours'] != null)
        ? double.tryParse(json['total_overtime_hours'].toString()) ?? 0.0
        : 0.0;

    final daysWorked = (json['total_days_worked'] != null)
        ? int.tryParse(json['total_days_worked'].toString()) ?? 0
        : (pCount + (hCount > 0 ? (hCount * 0.5).round() : 0));

    return LabourMonthlyRow(
      labourId: json['labour_id'] is int
          ? json['labour_id']
          : int.tryParse(json['labour_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Worker',
      role: json['role']?.toString() ?? 'Helper',
      wageType: json['wage_type']?.toString() ?? 'Daily Wage',
      monthlySalary: (json['monthly_salary'] != null)
          ? double.tryParse(json['monthly_salary'].toString()) ?? 0.0
          : 0.0,
      primarySiteId: json['primary_site_id'] != null
          ? int.tryParse(json['primary_site_id'].toString())
          : null,
      days: mappedDays,
      totalPresent: pCount,
      totalHalfDays: hCount,
      totalAbsent: aCount,
      totalPaidLeaves: plCount,
      totalOvertimeHours: otHours,
      totalDaysWorked: daysWorked,
    );
  }

  int get presentCount => totalPresent;
  int get halfDayCount => totalHalfDays;
  int get absentCount => totalAbsent;
  int get paidLeaveCount => totalPaidLeaves;
}

class LabourPayoutSummary {
  final int labourId;
  final String name;
  final String role;
  final String wageType;
  final double monthlySalary;
  final String siteName;
  final int daysPresent;
  final int halfDays;
  final int absentDays;
  final int paidLeaves;
  final double dailyRate;
  final double overtimeHours;
  final double overtimeRate;
  final double otEarning;
  final double totalAdvance;
  final double accruedCredit;
  final double netPayable;
  final double paidAmount;
  final String status; // 'Paid', 'Partial', 'Pending'

  LabourPayoutSummary({
    required this.labourId,
    required this.name,
    required this.role,
    required this.wageType,
    required this.monthlySalary,
    required this.siteName,
    required this.daysPresent,
    required this.halfDays,
    required this.absentDays,
    required this.paidLeaves,
    required this.dailyRate,
    required this.overtimeHours,
    required this.overtimeRate,
    required this.otEarning,
    required this.totalAdvance,
    required this.accruedCredit,
    required this.netPayable,
    required this.paidAmount,
    required this.status,
  });

  factory LabourPayoutSummary.fromJson(Map<String, dynamic> json) {
    final present = (json['days_present'] != null)
        ? int.tryParse(json['days_present'].toString()) ?? 0
        : 0;
    final half = (json['half_days'] != null)
        ? int.tryParse(json['half_days'].toString()) ?? 0
        : 0;
    final absent = (json['absent_days'] != null)
        ? int.tryParse(json['absent_days'].toString()) ?? 0
        : 0;
    final pl = (json['paid_leaves'] != null)
        ? int.tryParse(json['paid_leaves'].toString()) ?? 0
        : 0;
    final rate = (json['daily_rate'] != null)
        ? double.tryParse(json['daily_rate'].toString()) ?? 0.0
        : ((json['monthly_salary'] != null) ? double.tryParse(json['monthly_salary'].toString()) ?? 0.0 : 0.0);
    final otHrs = (json['overtime_hours'] != null)
        ? double.tryParse(json['overtime_hours'].toString()) ?? 0.0
        : 0.0;
    final otRate = (json['overtime_rate'] != null)
        ? double.tryParse(json['overtime_rate'].toString()) ?? 0.0
        : ((json['overtime_pay_per_hour'] != null) ? double.tryParse(json['overtime_pay_per_hour'].toString()) ?? 0.0 : 0.0);
    final otEarn = (json['ot_earning'] != null)
        ? double.tryParse(json['ot_earning'].toString()) ?? 0.0
        : (otHrs * otRate);
    final adv = (json['total_advance'] != null)
        ? double.tryParse(json['total_advance'].toString()) ?? 0.0
        : 0.0;
    final accrued = (json['accrued_credit'] != null)
        ? double.tryParse(json['accrued_credit'].toString()) ?? 0.0
        : ((present * rate) + (half * (rate * 0.5)) + (pl * rate) + otEarn);
    final net = (json['net_payable'] != null)
        ? double.tryParse(json['net_payable'].toString()) ?? 0.0
        : (accrued - adv);
    final paid = (json['paid_amount'] != null)
        ? double.tryParse(json['paid_amount'].toString()) ?? 0.0
        : 0.0;

    return LabourPayoutSummary(
      labourId: json['labour_id'] is int
          ? json['labour_id']
          : int.tryParse(json['labour_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Worker',
      role: json['role']?.toString() ?? 'Helper',
      wageType: json['wage_type']?.toString() ?? 'Daily Wage',
      monthlySalary: rate,
      siteName: json['site_name']?.toString() ?? 'Unassigned',
      daysPresent: present,
      halfDays: half,
      absentDays: absent,
      paidLeaves: pl,
      dailyRate: rate,
      overtimeHours: otHrs,
      overtimeRate: otRate,
      otEarning: otEarn,
      totalAdvance: adv,
      accruedCredit: accrued,
      netPayable: net,
      paidAmount: paid,
      status: json['status']?.toString() ?? (net <= 0 && accrued > 0 ? 'Paid' : (paid > 0 ? 'Partial' : 'Pending')),
    );
  }
}

class LabourHistoryTimeline {
  final int siteId;
  final String siteName;
  final String? locationDetails;
  final String? firstWorked;
  final String? lastWorked;
  final int totalDaysWorked;
  final int presentDays;
  final int halfDays;
  final int absentDays;
  final int paidLeaves;
  final double overtimeHours;
  final double totalEarned;

  LabourHistoryTimeline({
    required this.siteId,
    required this.siteName,
    this.locationDetails,
    this.firstWorked,
    this.lastWorked,
    required this.totalDaysWorked,
    required this.presentDays,
    required this.halfDays,
    required this.absentDays,
    required this.paidLeaves,
    required this.overtimeHours,
    required this.totalEarned,
  });

  factory LabourHistoryTimeline.fromJson(Map<String, dynamic> json) {
    return LabourHistoryTimeline(
      siteId: json['site_id'] is int ? json['site_id'] : int.tryParse(json['site_id'].toString()) ?? 0,
      siteName: json['site_name']?.toString() ?? 'Site',
      locationDetails: json['location_details']?.toString(),
      firstWorked: json['first_worked']?.toString(),
      lastWorked: json['last_worked']?.toString(),
      totalDaysWorked: int.tryParse(json['total_days_worked']?.toString() ?? '0') ?? 0,
      presentDays: int.tryParse(json['present_days']?.toString() ?? '0') ?? 0,
      halfDays: int.tryParse(json['half_days']?.toString() ?? '0') ?? 0,
      absentDays: int.tryParse(json['absent_days']?.toString() ?? '0') ?? 0,
      paidLeaves: int.tryParse(json['paid_leaves']?.toString() ?? '0') ?? 0,
      overtimeHours: double.tryParse(json['overtime_hours']?.toString() ?? '0.0') ?? 0.0,
      totalEarned: double.tryParse(json['total_earned']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class LabourHistoryPayout {
  final int? payoutId;
  final int? siteId;
  final String siteName;
  final String? month;
  final double accruedCredit;
  final double advancesTaken;
  final double netPayable;
  final double paidAmount;
  final String status;
  final String? paymentDate;
  final String? notes;

  LabourHistoryPayout({
    this.payoutId,
    this.siteId,
    required this.siteName,
    this.month,
    required this.accruedCredit,
    required this.advancesTaken,
    required this.netPayable,
    required this.paidAmount,
    required this.status,
    this.paymentDate,
    this.notes,
  });

  factory LabourHistoryPayout.fromJson(Map<String, dynamic> json) {
    return LabourHistoryPayout(
      payoutId: json['payout_id'] != null ? int.tryParse(json['payout_id'].toString()) : null,
      siteId: json['site_id'] != null ? int.tryParse(json['site_id'].toString()) : null,
      siteName: json['site_name']?.toString() ?? 'All Sites',
      month: json['month']?.toString(),
      accruedCredit: double.tryParse(json['accrued_credit']?.toString() ?? '0.0') ?? 0.0,
      advancesTaken: double.tryParse(json['advances_taken']?.toString() ?? '0.0') ?? 0.0,
      netPayable: double.tryParse(json['net_payable']?.toString() ?? '0.0') ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0.0') ?? 0.0,
      status: json['status']?.toString() ?? 'Paid',
      paymentDate: json['payment_date']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class LabourHistoryTotals {
  final int totalDaysWorked;
  final double totalEarned;
  final double totalAdvances;
  final double totalPayoutsReceived;

  LabourHistoryTotals({
    required this.totalDaysWorked,
    required this.totalEarned,
    required this.totalAdvances,
    required this.totalPayoutsReceived,
  });

  factory LabourHistoryTotals.fromJson(Map<String, dynamic> json) {
    return LabourHistoryTotals(
      totalDaysWorked: int.tryParse(json['total_days_worked']?.toString() ?? '0') ?? 0,
      totalEarned: double.tryParse(json['total_earned']?.toString() ?? '0.0') ?? 0.0,
      totalAdvances: double.tryParse(json['total_advances']?.toString() ?? '0.0') ?? 0.0,
      totalPayoutsReceived: double.tryParse(json['total_payouts_received']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class LabourWorkHistoryResult {
  final LabourWorker labour;
  final List<LabourHistoryTimeline> timeline;
  final List<LabourHistoryPayout> payouts;
  final LabourHistoryTotals totals;

  LabourWorkHistoryResult({
    required this.labour,
    required this.timeline,
    required this.payouts,
    required this.totals,
  });

  factory LabourWorkHistoryResult.fromJson(Map<String, dynamic> json) {
    final lab = json['labour'] is Map<String, dynamic>
        ? LabourWorker.fromJson(json['labour'])
        : LabourWorker(
            labourId: 0,
            name: 'Worker',
            sex: 'Male',
            role: 'Helper',
            wageType: 'Daily Wage',
            monthlySalary: 0.0,
            allowedLeaves: 0,
            overtimePayPerHour: 0.0,
            status: 'Active',
          );

    final rawTimeline = json['timeline'] as List? ?? [];
    final timelineList = rawTimeline.map((item) => LabourHistoryTimeline.fromJson(Map<String, dynamic>.from(item))).toList();

    final rawPayouts = json['payouts'] as List? ?? [];
    final payoutsList = rawPayouts.map((item) => LabourHistoryPayout.fromJson(Map<String, dynamic>.from(item))).toList();

    final totalsObj = json['totals'] is Map<String, dynamic>
        ? LabourHistoryTotals.fromJson(json['totals'])
        : LabourHistoryTotals(
            totalDaysWorked: 0,
            totalEarned: 0.0,
            totalAdvances: 0.0,
            totalPayoutsReceived: 0.0,
          );

    return LabourWorkHistoryResult(
      labour: lab,
      timeline: timelineList,
      payouts: payoutsList,
      totals: totalsObj,
    );
  }
}

class ParsedLabourRow {
  final String name;
  final String phone;
  final String sex;
  final String role;
  final String wageType;
  final dynamic monthlySalary;
  final double overtimePayPerHour;
  final int? siteId;
  final String siteName;
  final bool isValid;
  final String error;

  ParsedLabourRow({
    required this.name,
    required this.phone,
    required this.sex,
    required this.role,
    required this.wageType,
    required this.monthlySalary,
    required this.overtimePayPerHour,
    this.siteId,
    required this.siteName,
    required this.isValid,
    required this.error,
  });

  factory ParsedLabourRow.fromJson(Map<String, dynamic> json) {
    return ParsedLabourRow(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      sex: json['sex']?.toString() ?? 'Male',
      role: json['role']?.toString() ?? 'Helper',
      wageType: json['wage_type']?.toString() ?? 'Daily Wage',
      monthlySalary: json['monthly_salary'] ?? 0,
      overtimePayPerHour: double.tryParse(json['overtime_pay_per_hour']?.toString() ?? '0.0') ?? 0.0,
      siteId: json['site_id'] != null ? int.tryParse(json['site_id'].toString()) : null,
      siteName: json['site_name']?.toString() ?? '',
      isValid: json['isValid'] == true,
      error: json['error']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'phone': phone.isEmpty ? null : phone,
      'sex': sex,
      'role': role,
      'wage_type': wageType,
      'monthly_salary': double.tryParse(monthlySalary.toString()) ?? 0.0,
      'allowed_leaves': 0,
      'overtime_pay_per_hour': overtimePayPerHour,
      'site_id': siteId,
    };
  }
}

// [upd:2026-04-09T17:00:00+05:30]
