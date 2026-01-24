class CorrectionRequest {
  final int id;
  final int userId;
  final String? userName; // May be null if not joined
  final String? userAvatar; // Optional
  final String correctionType;
  final String requestDate; // YYYY-MM-DD
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewComments;
  final String createdAt;

  CorrectionRequest({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.correctionType,
    required this.requestDate,
    required this.reason,
    required this.status,
    this.reviewComments,
    required this.createdAt,
  });

  factory CorrectionRequest.fromJson(Map<String, dynamic> json) {
    return CorrectionRequest(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Unknown User',
      userAvatar: json['user_avatar'],
      correctionType: json['correction_type'],
      requestDate: json['request_date'],
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      reviewComments: json['review_comments'],
      createdAt: json['created_at'] ?? '',
    );
  }
  
  String get typeLabel {
    switch (correctionType) {
      case 'missed_punch': return 'Missed Punch';
      case 'late_entry': return 'Late Entry';
      case 'early_exit': return 'Early Exit';
      case 'wrong_location': return 'Wrong Location';
      default: return correctionType.replaceAll('_', ' ').toUpperCase();
    }
  }
}
