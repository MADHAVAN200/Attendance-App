class Leave {
  final int id;
  final String type;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? document;
  final String? appliedOn;

  Leave({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.document,
    this.appliedOn,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['leave_id'] ?? 0,
      type: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      document: json['document'],
      appliedOn: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_id': id,
      'leave_type': type,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': status,
      'document': document,
    };
  }
}
