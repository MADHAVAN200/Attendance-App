import 'package:intl/intl.dart';

enum PayrollStatus {
  draft,
  processing,
  approved,
  disbursed,
}

extension PayrollStatusExtension on PayrollStatus {
  String get label {
    switch (this) {
      case PayrollStatus.draft:
        return 'Draft';
      case PayrollStatus.processing:
        return 'Processing';
      case PayrollStatus.approved:
        return 'Approved';
      case PayrollStatus.disbursed:
        return 'Disbursed';
    }
  }
}

class SalaryBreakdown {
  final double basic;
  final double hra;
  final double specialAllowance;
  final double overtimePay;
  final double pf; // Provident Fund (12% of basic)
  final double esi; // Employee State Insurance (0.75% of gross)
  final double tds; // Tax Deducted at Source
  final double salaryAdvance; // Loan / Advance deduction
  final double leaveDeductions; // Deduction for unpaid leaves

  const SalaryBreakdown({
    required this.basic,
    required this.hra,
    required this.specialAllowance,
    this.overtimePay = 0.0,
    required this.pf,
    required this.esi,
    required this.tds,
    this.salaryAdvance = 0.0,
    this.leaveDeductions = 0.0,
  });

  double get totalEarnings => basic + hra + specialAllowance + overtimePay;

  double get totalDeductions => pf + esi + tds + salaryAdvance + leaveDeductions;

  double get netSalary => totalEarnings - totalDeductions;

  factory SalaryBreakdown.calculate({
    required double monthlyGross,
    double overtimeHours = 0.0,
    double overtimeRate = 250.0,
    int unpaidLeaves = 0,
    int totalWorkingDays = 26,
    double salaryAdvance = 0.0,
    double tdsRate = 0.05, // 5% default estimated TDS
  }) {
    // Standard Indian Payroll Distribution:
    // Basic = 50% of Gross
    // HRA = 40% of Basic (20% of Gross)
    // Special Allowance = Remaining 30% of Gross
    final basic = (monthlyGross * 0.50).roundToDouble();
    final hra = (basic * 0.40).roundToDouble();
    final specialAllowance = (monthlyGross - basic - hra).roundToDouble();

    // Overtime
    final overtimePay = (overtimeHours * overtimeRate).roundToDouble();

    // Unpaid leave deduction = (Gross / workingDays) * unpaidLeaves
    final dailyRate = totalWorkingDays > 0 ? (monthlyGross / totalWorkingDays) : 0.0;
    final leaveDeductions = (dailyRate * unpaidLeaves).roundToDouble();

    // Deductions
    // PF = 12% of Basic (capped if basic > 15000, but standard 12%)
    final pf = (basic * 0.12).roundToDouble();

    // ESI = 0.75% of Gross (applicable if gross <= 21000, here computed standard)
    final grossForEsi = monthlyGross + overtimePay - leaveDeductions;
    final esi = grossForEsi <= 21000 ? (grossForEsi * 0.0075).roundToDouble() : 0.0;

    // TDS estimated
    final taxableGross = grossForEsi - pf;
    final tds = taxableGross > 30000 ? (taxableGross * tdsRate).roundToDouble() : 0.0;

    return SalaryBreakdown(
      basic: basic,
      hra: hra,
      specialAllowance: specialAllowance,
      overtimePay: overtimePay,
      pf: pf,
      esi: esi,
      tds: tds,
      salaryAdvance: salaryAdvance,
      leaveDeductions: leaveDeductions,
    );
  }

  Map<String, dynamic> toJson() => {
        'basic': basic,
        'hra': hra,
        'specialAllowance': specialAllowance,
        'overtimePay': overtimePay,
        'pf': pf,
        'esi': esi,
        'tds': tds,
        'salaryAdvance': salaryAdvance,
        'leaveDeductions': leaveDeductions,
      };

  factory SalaryBreakdown.fromJson(Map<String, dynamic> json) => SalaryBreakdown(
        basic: (json['basic'] as num?)?.toDouble() ?? 0.0,
        hra: (json['hra'] as num?)?.toDouble() ?? 0.0,
        specialAllowance: (json['specialAllowance'] as num?)?.toDouble() ?? 0.0,
        overtimePay: (json['overtimePay'] as num?)?.toDouble() ?? 0.0,
        pf: (json['pf'] as num?)?.toDouble() ?? 0.0,
        esi: (json['esi'] as num?)?.toDouble() ?? 0.0,
        tds: (json['tds'] as num?)?.toDouble() ?? 0.0,
        salaryAdvance: (json['salaryAdvance'] as num?)?.toDouble() ?? 0.0,
        leaveDeductions: (json['leaveDeductions'] as num?)?.toDouble() ?? 0.0,
      );
}

class Payslip {
  final String id;
  final String employeeId;
  final String employeeName;
  final String designation;
  final String department;
  final String panNumber;
  final String bankAccount;
  final String payPeriod; // e.g. "August 2026"
  final int totalWorkingDays;
  final int presentDays;
  final int unpaidLeaves;
  final double overtimeHours;
  final SalaryBreakdown breakdown;
  final PayrollStatus status;
  final DateTime generatedDate;

  Payslip({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.designation,
    required this.department,
    this.panNumber = 'ABCDE1234F',
    this.bankAccount = 'XXXX-XXXX-9876',
    required this.payPeriod,
    this.totalWorkingDays = 26,
    this.presentDays = 24,
    this.unpaidLeaves = 2,
    this.overtimeHours = 5.0,
    required this.breakdown,
    this.status = PayrollStatus.approved,
    DateTime? generatedDate,
  }) : generatedDate = generatedDate ?? DateTime.now();

  double get netPay => breakdown.netSalary;

  String get formattedNetPay => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(netPay);
  String get formattedGross => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(breakdown.totalEarnings);
  String get formattedDeductions => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(breakdown.totalDeductions);

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'designation': designation,
        'department': department,
        'panNumber': panNumber,
        'bankAccount': bankAccount,
        'payPeriod': payPeriod,
        'totalWorkingDays': totalWorkingDays,
        'presentDays': presentDays,
        'unpaidLeaves': unpaidLeaves,
        'overtimeHours': overtimeHours,
        'breakdown': breakdown.toJson(),
        'status': status.name,
        'generatedDate': generatedDate.toIso8601String(),
      };

  factory Payslip.fromJson(Map<String, dynamic> json) => Payslip(
        id: json['id'] ?? '',
        employeeId: json['employeeId'] ?? '',
        employeeName: json['employeeName'] ?? 'Employee',
        designation: json['designation'] ?? 'Staff',
        department: json['department'] ?? 'General',
        panNumber: json['panNumber'] ?? 'ABCDE1234F',
        bankAccount: json['bankAccount'] ?? 'XXXX-XXXX-9876',
        payPeriod: json['payPeriod'] ?? '',
        totalWorkingDays: json['totalWorkingDays'] ?? 26,
        presentDays: json['presentDays'] ?? 26,
        unpaidLeaves: json['unpaidLeaves'] ?? 0,
        overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0.0,
        breakdown: json['breakdown'] != null
            ? SalaryBreakdown.fromJson(json['breakdown'])
            : SalaryBreakdown.calculate(monthlyGross: 45000),
        status: PayrollStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PayrollStatus.approved,
        ),
        generatedDate: json['generatedDate'] != null
            ? DateTime.tryParse(json['generatedDate']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class PayrollRun {
  final String id;
  final String payPeriod; // "August 2026"
  final PayrollStatus status;
  final int totalEmployees;
  final double totalGrossPayout;
  final double totalDeductions;
  final double totalNetPayout;
  final DateTime processedDate;
  final bool isLocked;

  PayrollRun({
    required this.id,
    required this.payPeriod,
    required this.status,
    required this.totalEmployees,
    required this.totalGrossPayout,
    required this.totalDeductions,
    required this.totalNetPayout,
    required this.processedDate,
    this.isLocked = false,
  });

  String get formattedTotalNet => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(totalNetPayout);
  String get formattedTotalGross => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(totalGrossPayout);
  String get formattedTotalDeductions => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(totalDeductions);
}

class SalaryPackage {
  final String id;
  final String employeeId;
  final String employeeName;
  final double annualCtc;
  final double monthlyGross;
  final bool isPfApplicable;
  final bool isEsiApplicable;

  SalaryPackage({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.annualCtc,
  }) : monthlyGross = annualCtc / 12,
       isPfApplicable = true,
       isEsiApplicable = (annualCtc / 12) <= 21000;

  String get formattedCtc => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(annualCtc);
  String get formattedMonthlyGross => NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(monthlyGross);
}

/// Helper utility to convert a number to Indian currency words
String numberToWords(double number) {
  final int val = number.round();
  if (val == 0) return "Zero Rupees";

  final units = [
    "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
    "Seventeen", "Eighteen", "Nineteen"
  ];

  final tens = [
    "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
  ];

  String convertChunk(int n) {
    if (n < 20) return units[n];
    if (n < 100) return "${tens[n ~/ 10]} ${units[n % 10]}".trim();
    if (n < 1000) return "${units[n ~/ 100]} Hundred ${convertChunk(n % 100)}".trim();
    return "";
  }

  int temp = val;
  String result = "";

  if (temp >= 10000000) { // Crore
    result += "${convertChunk(temp ~/ 10000000)} Crore ";
    temp %= 10000000;
  }
  if (temp >= 100000) { // Lakh
    result += "${convertChunk(temp ~/ 100000)} Lakh ";
    temp %= 100000;
  }
  if (temp >= 1000) { // Thousand
    result += "${convertChunk(temp ~/ 1000)} Thousand ";
    temp %= 1000;
  }
  if (temp > 0) {
    result += convertChunk(temp);
  }

  return "Rupees ${result.trim()} Only";
}
