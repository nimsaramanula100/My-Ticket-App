// lib/models/organizer.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrganizerVerificationStatus { pending, verified, rejected, suspended }

class Organizer {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String profileImage;
  final String website;
  final OrganizerVerificationStatus verificationStatus;
  final int eventsCount;
  final double totalRevenue;
  final int totalAttendees;
  final DateTime createdAt;
  final List<String> socialLinks;

  Organizer({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.profileImage = '',
    this.website = '',
    this.verificationStatus = OrganizerVerificationStatus.pending,
    this.eventsCount = 0,
    this.totalRevenue = 0.0,
    this.totalAttendees = 0,
    DateTime? createdAt,
    this.socialLinks = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  String get verificationStatusText {
    switch (verificationStatus) {
      case OrganizerVerificationStatus.pending:
        return 'Pending Review';
      case OrganizerVerificationStatus.verified:
        return 'Verified';
      case OrganizerVerificationStatus.rejected:
        return 'Rejected';
      case OrganizerVerificationStatus.suspended:
        return 'Suspended';
    }
  }

  bool get isVerified => verificationStatus == OrganizerVerificationStatus.verified;

  factory Organizer.fromMap(Map<String, dynamic> data, String id) {
    OrganizerVerificationStatus status;
    switch (data['verificationStatus']) {
      case 'verified':
        status = OrganizerVerificationStatus.verified;
        break;
      case 'rejected':
        status = OrganizerVerificationStatus.rejected;
        break;
      case 'suspended':
        status = OrganizerVerificationStatus.suspended;
        break;
      default:
        status = OrganizerVerificationStatus.pending;
    }

    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    return Organizer(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      bio: data['bio'] ?? '',
      profileImage: data['profileImage'] ?? '',
      website: data['website'] ?? '',
      verificationStatus: status,
      eventsCount: data['eventsCount'] ?? 0,
      totalRevenue: double.tryParse(data['totalRevenue'].toString()) ?? 0.0,
      totalAttendees: data['totalAttendees'] ?? 0,
      createdAt: createdAt,
      socialLinks: List<String>.from(data['socialLinks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'bio': bio,
    'profileImage': profileImage,
    'website': website,
    'verificationStatus': verificationStatus.name,
    'eventsCount': eventsCount,
    'totalRevenue': totalRevenue,
    'totalAttendees': totalAttendees,
    'createdAt': FieldValue.serverTimestamp(),
    'socialLinks': socialLinks,
  };

  Organizer copyWith({
    String? name,
    String? phone,
    String? bio,
    String? profileImage,
    String? website,
    OrganizerVerificationStatus? verificationStatus,
    int? eventsCount,
    double? totalRevenue,
    int? totalAttendees,
    List<String>? socialLinks,
  }) {
    return Organizer(
      id: id,
      userId: userId,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      website: website ?? this.website,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      eventsCount: eventsCount ?? this.eventsCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalAttendees: totalAttendees ?? this.totalAttendees,
      createdAt: createdAt,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }
}
