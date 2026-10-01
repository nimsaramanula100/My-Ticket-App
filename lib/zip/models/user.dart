// lib/models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, organizer, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final UserRole role;
  final String? organizerId;
  final List<String> favoriteEventIds;
  final bool notificationsEnabled;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.profileImage = '',
    this.role = UserRole.user,
    this.organizerId,
    this.favoriteEventIds = const [],
    this.notificationsEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOrganizer => role == UserRole.organizer;
  bool get isAdmin => role == UserRole.admin;

  String get roleText {
    switch (role) {
      case UserRole.user: return 'user';
      case UserRole.organizer: return 'organizer';
      case UserRole.admin: return 'admin';
    }
  }

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    UserRole role;
    switch (data['role']) {
      case 'organizer': role = UserRole.organizer; break;
      case 'admin': role = UserRole.admin; break;
      default: role = UserRole.user;
    }

    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      role: role,
      organizerId: data['organizerId'],
      favoriteEventIds: List<String>.from(data['favoriteEventIds'] ?? []),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'profileImage': profileImage,
    'role': roleText,
    'organizerId': organizerId,
    'favoriteEventIds': favoriteEventIds,
    'notificationsEnabled': notificationsEnabled,
    'createdAt': FieldValue.serverTimestamp(),
  };

  AppUser copyWith({
    String? name,
    String? phone,
    String? profileImage,
    UserRole? role,
    String? organizerId,
    List<String>? favoriteEventIds,
    bool? notificationsEnabled,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      organizerId: organizerId ?? this.organizerId,
      favoriteEventIds: favoriteEventIds ?? this.favoriteEventIds,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
    );
  }
}

// Legacy alias so old code doesn't break
typedef User = AppUser;
