class WorkLocation {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int radius; // in meters
  final bool isActive;

  WorkLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isActive,
  });

  factory WorkLocation.fromJson(Map<String, dynamic> json) {
    return WorkLocation(
      id: json['location_id'],
      name: json['location_name'],
      address: json['address'] ?? '',
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      radius: json['radius'] ?? 100,
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'is_active': isActive ? 1 : 0
    };
  }
}
