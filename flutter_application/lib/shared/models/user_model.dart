class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String role;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'User',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      // Normalize role to lowercase to ensure consistent comparison
      role: (json['role'] ?? json['user_type'] ?? 'employee').toString().toLowerCase(),
      profileImage: json['profile_image'],
    );
  }

  bool get isAdmin => role == 'admin' || role == 'hr';
  bool get isEmployee => role == 'employee';
}
