class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final DateTime createdAt;
  final String role; // 'user' or 'admin'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.createdAt,
    this.role = 'user',
  });

  factory User.fromMap(Map<String, dynamic> data, String docId) {
    return User(
      id: docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
    };
  }
}
