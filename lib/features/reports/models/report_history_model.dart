class ReportHistory {
  final String fileName;
  final String path;
  final String timestamp;
  final String type;

  ReportHistory({
    required this.fileName,
    required this.path,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'path': path,
    'timestamp': timestamp,
    'type': type,
  };

  factory ReportHistory.fromJson(Map<String, dynamic> json) {
    return ReportHistory(
      fileName: json['fileName'],
      path: json['path'],
      timestamp: json['timestamp'],
      type: json['type'],
    );
  }
}
