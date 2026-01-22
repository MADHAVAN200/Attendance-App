class Shift {
  final int? id;
  final String name;
  final String startTime; // "HH:MM"
  final String endTime;   // "HH:MM"
  final int gracePeriodMins;
  final bool isOvertimeEnabled;
  final double overtimeThresholdHours;

  Shift({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriodMins, 
    required this.isOvertimeEnabled,
    required this.overtimeThresholdHours,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['shift_id'],
      name: json['shift_name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      gracePeriodMins: json['grace_period_mins'] ?? 0,
       // Handle DB int/bool conversion (0/1 or true/false)
      isOvertimeEnabled: json['is_overtime_enabled'] == 1 || json['is_overtime_enabled'] == true,
      overtimeThresholdHours: double.tryParse(json['overtime_threshold_hours'].toString()) ?? 8.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift_name': name,
      'start_time': startTime,
      'end_time': endTime,
      'grace_period_mins': gracePeriodMins,
      // API expects bool for POST/PUT? snippet says boolean in body example
      'is_overtime_enabled': isOvertimeEnabled,
      'overtime_threshold_hours': overtimeThresholdHours,
    };
  }
}
