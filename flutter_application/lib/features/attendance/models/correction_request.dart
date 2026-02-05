
enum CorrectionType { missedPunch, regularization, overtime, other }
enum CorrectionMethod { fix, addSession, reset }
enum RequestStatus { pending, approved, rejected }

class AttendanceCorrectionRequest {
  final String id;
  final String userId;
  final String userName; // For Admin display
  final String? userAvatar; // ADDED: Backward compatibility
  final DateTime requestDate;
  final CorrectionType type;
  final CorrectionMethod method;
  final String reason;
  final RequestStatus status;
  
  // For 'fix' or 'reset'
  final String? requestedTimeIn;
  final String? requestedTimeOut;
  
  // For 'add_session'
  final List<Map<String, String>>? requestedSessions;
  
  // Admin Review
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewComments;

  AttendanceCorrectionRequest({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.requestDate,
    required this.type,
    required this.method,
    required this.reason,
    this.status = RequestStatus.pending,
    this.requestedTimeIn,
    this.requestedTimeOut,
    this.requestedSessions,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewComments,
  });

  factory AttendanceCorrectionRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceCorrectionRequest(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? 'Unknown',
      requestDate: DateTime.parse(json['request_date']),
      type: _parseType(json['correction_type']),
      method: _parseMethod(json['correction_method']),
      reason: json['reason'] ?? '',
      status: _parseStatus(json['status']),
      requestedTimeIn: json['requested_time_in'],
      requestedTimeOut: json['requested_time_out'],
      requestedSessions: json['requested_sessions'] != null 
          ? List<Map<String, String>>.from((json['requested_sessions'] as List).map((x) => Map<String, String>.from(x)))
          : null,
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      reviewComments: json['review_comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'request_date': requestDate.toIso8601String(),
      'correction_type': type.toString().split('.').last,
      'correction_method': method.toString().split('.').last,
      'reason': reason,
      'status': status.toString().split('.').last,
      'requested_time_in': requestedTimeIn,
      'requested_time_out': requestedTimeOut,
      'requested_sessions': requestedSessions,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_comments': reviewComments,
    };
  }

  static CorrectionType _parseType(String? val) {
    return CorrectionType.values.firstWhere(
      (e) => e.toString().split('.').last == val, 
      orElse: () => CorrectionType.other
    );
  }

  static CorrectionMethod _parseMethod(String? val) {
    return CorrectionMethod.values.firstWhere(
      (e) => e.toString().split('.').last == val, 
      orElse: () => CorrectionMethod.fix
    );
  }

  static RequestStatus _parseStatus(String? val) {
    return RequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == val, 
      orElse: () => RequestStatus.pending
    );
  }

  // Backward Compatibility / Helpers
  String get createdAt => requestDate.toIso8601String();
  
  String get typeLabel {
    switch (type) {
      case CorrectionType.missedPunch: return 'Missed Punch';
      case CorrectionType.regularization: return 'Regularization';
      case CorrectionType.overtime: return 'Overtime';
      default: return type.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
    }
  }
}

