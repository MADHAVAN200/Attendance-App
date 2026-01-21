class Holiday {
  final int id;
  final String name;
  final String date; // YYYY-MM-DD
  final String type; // 'Public', 'Optional', 'Observance'
  final String? applicableJson; // JSON string for locations

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    this.applicableJson,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: int.tryParse(json['holiday_id'].toString()) ?? 0,
      name: json['holiday_name']?.toString() ?? '',
      date: (json['holiday_date']?.toString() ?? '').split('T')[0],
      type: json['holiday_type']?.toString() ?? 'Public',
      applicableJson: json['applicable_json']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holiday_name': name,
      'holiday_date': date,
      'holiday_type': type,
      'applicable_json': applicableJson ?? '["All Locations"]'
    };
  }
}
