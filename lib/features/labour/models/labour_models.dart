class LabourSite {
  final int siteId;
  final String siteName;
  final String? locationDetails;
  final String status;
  final String? endDate;

  LabourSite({
    required this.siteId,
    required this.siteName,
    this.locationDetails,
    required this.status,
    this.endDate,
  });

  factory LabourSite.fromJson(Map<String, dynamic> json) {
    return LabourSite(
      siteId: json['site_id'] is int ? json['site_id'] : int.tryParse(json['site_id'].toString()) ?? 0,
      siteName: json['site_name']?.toString() ?? 'Unnamed Site',
      locationDetails: json['location_details']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      endDate: json['end_date']?.toString(),
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
  final String role; // Skill mapping (e.g. Mason, Carpenter, Electrician, Plumber, Helper, etc.)
  final String wageType;
  final double monthlySalary; // Used as Daily Wage Amount
  final int allowedLeaves;
  final int? siteId;
  final String? siteName;
  final List<int> siteIds;
  final double overtimePayPerHour;
  final String status;

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
    this.siteName,
    this.siteIds = const [],
    required this.overtimePayPerHour,
    required this.status,
  });

  factory LabourWorker.fromJson(Map<String, dynamic> json) {
    List<int> sIds = [];
    if (json['site_ids'] != null && json['site_ids'] is List) {
      sIds = (json['site_ids'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }

    String siteStr = 'Unassigned';
    if (json['site_name'] != null && json['site_name'].toString().isNotEmpty) {
      siteStr = json['site_name'].toString();
      if (siteStr.contains(',')) {
        siteStr = siteStr.split(',').first.trim();
      }
    }

    return LabourWorker(
      labourId: json['labour_id'] is int ? json['labour_id'] : int.tryParse(json['labour_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Worker',
      phone: json['phone']?.toString(),
      sex: json['sex']?.toString() ?? 'Male',
      role: json['role']?.toString() ?? 'Helper',
      wageType: json['wage_type']?.toString() ?? 'Daily Wage',
      monthlySalary: (json['monthly_salary'] != null) ? double.tryParse(json['monthly_salary'].toString()) ?? 0.0 : 0.0,
      allowedLeaves: (json['allowed_leaves'] != null) ? int.tryParse(json['allowed_leaves'].toString()) ?? 0 : 0,
      siteId: json['site_id'] != null ? int.tryParse(json['site_id'].toString()) : null,
      siteName: siteStr,
      siteIds: sIds,
      overtimePayPerHour: (json['overtime_pay_per_hour'] != null) ? double.tryParse(json['overtime_pay_per_hour'].toString()) ?? 0.0 : 0.0,
      status: json['status']?.toString() ?? 'Active',
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
  String status; // Present, Absent, Half Day, Paid Leave
  double overtimeHours;
  final double overtimePayPerHour;
  final int? primarySiteId;

  LabourAttendanceItem({
    required this.labourId,
    required this.name,
    required this.role,
    required this.wageType,
    required this.status,
    required this.overtimeHours,
    required this.overtimePayPerHour,
    this.primarySiteId,
  });

  factory LabourAttendanceItem.fromJson(Map<String, dynamic> json) {
    return LabourAttendanceItem(
      labourId: json['labour_id'] is int ? json['labour_id'] : int.tryParse(json['labour_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Worker',
      role: json['role']?.toString() ?? 'Helper',
      wageType: json['wage_type']?.toString() ?? 'Daily Wage',
      status: json['status']?.toString() ?? '',
      overtimeHours: (json['overtime_hours'] != null) ? double.tryParse(json['overtime_hours'].toString()) ?? 0.0 : 0.0,
      overtimePayPerHour: (json['overtime_pay_per_hour'] != null) ? double.tryParse(json['overtime_pay_per_hour'].toString()) ?? 0.0 : 0.0,
      primarySiteId: json['primary_site_id'] != null ? int.tryParse(json['primary_site_id'].toString()) : null,
    );
  }
}

class LabourPayoutSummary {
  final int labourId;
  final String name;
  final String role;
  final String siteName;
  final int daysPresent;
  final double dailyRate;
  final double overtimeHours;
  final double overtimeRate;
  final double totalAdvance;
  final double totalEarned;
  final double netPayout;
  final String status;

  LabourPayoutSummary({
    required this.labourId,
    required this.name,
    required this.role,
    required this.siteName,
    required this.daysPresent,
    required this.dailyRate,
    required this.overtimeHours,
    required this.overtimeRate,
    required this.totalAdvance,
    required this.totalEarned,
    required this.netPayout,
    required this.status,
  });

  factory LabourPayoutSummary.fromJson(Map<String, dynamic> json) {
    final present = (json['days_present'] != null) ? int.tryParse(json['days_present'].toString()) ?? 0 : 0;
    final rate = (json['daily_rate'] != null) ? double.tryParse(json['daily_rate'].toString()) ?? 0.0 : 0.0;
    final otHrs = (json['overtime_hours'] != null) ? double.tryParse(json['overtime_hours'].toString()) ?? 0.0 : 0.0;
    final otRate = (json['overtime_rate'] != null) ? double.tryParse(json['overtime_rate'].toString()) ?? 0.0 : 0.0;
    final adv = (json['total_advance'] != null) ? double.tryParse(json['total_advance'].toString()) ?? 0.0 : 0.0;

    final earned = (present * rate) + (otHrs * otRate);
    final net = earned - adv;

    return LabourPayoutSummary(
      labourId: json['labour_id'] is int ? json['labour_id'] : int.tryParse(json['labour_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Worker',
      role: json['role']?.toString() ?? 'Helper',
      siteName: json['site_name']?.toString() ?? 'Unassigned',
      daysPresent: present,
      dailyRate: rate,
      overtimeHours: otHrs,
      overtimeRate: otRate,
      totalAdvance: adv,
      totalEarned: earned,
      netPayout: net > 0 ? net : 0.0,
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}
