// lib/models/user.dart
// ─────────────────────────────────────────────────────────────────────────────
// AppUser Model | AppUser ආකෘතිය
// Represents a registered user in the application.
// යෙදුමේ ලියාපදිංචි පරිශීලකයෙකු නිරූපණය කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum defining the role of a user | පරිශීලකයාගේ භූමිකාව නිර්වචනය කරන Enum
// user = normal ticket buyer | user = සාමාන්‍ය ticket ගෝලකරු
// organizer = event organizer | organizer = සිදුවීම් සංවිධායකයා
// admin = system administrator | admin = පද්ධති පරිපාලක
enum UserRole { user, organizer, admin }

// ─── AppUser Class | AppUser පන්තිය ──────────────────────────────────────────
// Holds all information about a single app user.
// එකම app පරිශීලකයෙකු ගැන සියලු තොරතුරු ඇතුළත් කරයි.
class AppUser {
  // Firestore document ID / Firebase Auth UID | Firestore ලේඛන ID
  final String id;

  // Full name of the user | පරිශීලකයාගේ සම්පූර්ණ නම
  final String name;

  // Email address | ඊමේල් ලිපිනය
  final String email;

  // Mobile phone number | ජංගම දුරකථන අංකය
  final String phone;

  // URL to the profile picture | පැතිකඩ රූපයේ URL
  final String profileImage;

  // User role (user, organizer, or admin) | පරිශීලකයාගේ භූමිකාව
  final UserRole role;

  // If the user is an organizer, links to their Organizer document
  // පරිශීලකයා organizer නම්, ඔවුන්ගේ Organizer ලේඛනයට සම්බන්ධ වේ
  final String? organizerId;

  // List of event IDs the user has saved/favorited
  // පරිශීලකයා ප්‍රිය කළ/සුරැකූ සිදුවීම් ID ලැයිස්තුව
  final List<String> favoriteEventIds;

  // Whether the user wants push notifications | Push notification අවශ්‍ය ද
  final bool notificationsEnabled;

  // Account creation timestamp | ගිණුම සෑදූ කාල මුද්‍රාව
  final DateTime createdAt;

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
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

  // Convenience bool getters for role checks | භූමිකා පරීක්ෂාව සඳහා bool getters
  bool get isOrganizer => role == UserRole.organizer;
  bool get isAdmin => role == UserRole.admin;

  // Returns the role as a plain string for Firestore storage
  // Firestore ගබඩා කිරීමට role string ලෙස ලබා දෙයි
  String get roleText {
    switch (role) {
      case UserRole.user: return 'user';
      case UserRole.organizer: return 'organizer';
      case UserRole.admin: return 'admin';
    }
  }

  // Returns name if set, otherwise part of the email address before '@'
  // නම සැකසී ඇත්නම් නම, නැතිනම් email ලිපිනයේ '@' ට පෙර කොටස ලබා දෙයි
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  // Returns initials from the user's name for avatar display
  // Avatar ප්‍රදර්ශනය සඳහා නමේ මූලාක්ෂර ලබා දෙයි (e.g. "JD" for "John Doe")
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      // First letter of first two words | පළමු වචන දෙකේ මුල් අකුර
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      // Only one word: use first letter | එකම වචනය: පළමු අකුර
      return parts[0][0].toUpperCase();
    }
    // Fallback to 'U' | Fallback 'U'
    return 'U';
  }

  // ─── Factory constructor from Firestore Map | Firestore Map වලින් factory constructor ───
  // Converts a Firestore document snapshot into an AppUser object.
  // Firestore ලේඛන snapshot AppUser object බවට පරිවර්තනය කරයි.
  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    // Parse user role string into the enum | role string enum බවට parse කරයි
    UserRole role;
    switch (data['role']) {
      case 'organizer': role = UserRole.organizer; break;
      case 'admin': role = UserRole.admin; break;
      default: role = UserRole.user;
    }

    // Parse the Firestore Timestamp for createdAt
    // createdAt සඳහා Firestore Timestamp parse කරයි
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    // Build and return the AppUser object | AppUser object ගොඩනගා ලබා දෙයි
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

  // ─── Convert AppUser to Map for Firestore | Firestore සඳහා Map බවට ───────────
  // Turns the object into a key-value map to save to Firestore.
  // object key-value map එකක් බවට හරවා Firestore හි සුරකිනු ලැබේ.
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'profileImage': profileImage,
    'role': roleText,
    'organizerId': organizerId,
    'favoriteEventIds': favoriteEventIds,
    'notificationsEnabled': notificationsEnabled,
    // Use server timestamp so it's consistent across time zones
    // Time zone වෙනස්කම් නොමැතිව consistent ලෙස server timestamp භාවිතා කරයි
    'createdAt': FieldValue.serverTimestamp(),
  };

  // ─── copyWith — Creates a modified copy | වෙනස් කළ copy ────────────────────
  // Returns a new AppUser with selected fields updated; all other fields stay the same.
  // තෝරාගත් ක්ෂේත්‍ර යාවත්කාලීන කළ නව AppUser ලබා දෙයි; අනෙක් ක්ෂේත්‍ර එලෙසම.
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
      email: email, // email is immutable | email වෙනස් නොවේ
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

// Legacy alias so old code referring to 'User' still compiles
// 'User' ලෙස යොමු කළ පැරණි code compile වීමට Legacy alias
typedef User = AppUser;
