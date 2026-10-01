// lib/models/organizer.dart
// ─────────────────────────────────────────────────────────────────────────────
// Organizer Model | සංවිධායක ආකෘතිය
// Represents an event organizer profiles in the application.
// යෙදුමේ සිදුවීම් සංවිධායක පැතිකඩක් නිරූපණය කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum defining the verification status of an organizer
// සංවිධායකවරයෙකුගේ සත්‍යාපන තත්වය නිර්වචනය කරන Enum එක
enum OrganizerVerificationStatus { pending, verified, rejected, suspended }

// ─── Organizer Class | සංවිධායක පන්තිය ──────────────────────────────────────────
// Holds details of a registered organizer entity.
// ලියාපදිංචි සංවිධායක ආයතනයක විස්තර ඇතුළත් කරයි.
class Organizer {
  // Unique organizer ID in Firestore | Firestore හි ඇති අද්විතීය සංවිධායක ID එක
  final String id;

  // Linked user ID of the organizer | සංවිධායකගේ සම්බන්ධිත පරිශීලක ID එක
  final String userId;

  // Name of the organizing group/company | සංවිධායක කණ්ඩායමේ හෝ සමාගමේ නම
  final String name;

  // Public/Contact Email address | පොදු/සම්බන්ධතා ඊමේල් ලිපිනය
  final String email;

  // Public/Contact Phone number | පොදු/සම්බන්ධතා දුරකථන අංකය
  final String phone;

  // Bio description about the organizer | සංවිධායක පිළිබඳ කෙටි විස්තරයක්
  final String bio;

  // Profile banner or avatar photo URL | පැතිකඩ බැනරයේ හෝ ඡායාරූපයේ URL එක
  final String profileImage;

  // Official website URL | නිල වෙබ් අඩවියේ URL එක
  final String website;

  // Verification status of the organizer profile | සංවිධායක පැතිකඩෙහි සත්‍යාපන තත්වය
  final OrganizerVerificationStatus verificationStatus;

  // Count of total events published by this organizer | මෙම සංවිධායක පළකර ඇති මුළු සිදුවීම් ගණන
  final int eventsCount;

  // Total revenue earned through ticket bookings | ප්‍රවේශපත්‍ර වෙන්කිරීම් මඟින් උපයා ඇති මුළු ආදායම
  final double totalRevenue;

  // Total attendees who booked their events | සිදුවීම් වෙන්කරවාගත් මුළු සහභාගිවන්නන් ගණන
  final int totalAttendees;

  // Account creation timestamp | ගිණුම නිර්මාණය කළ කාල මුද්‍රාව
  final DateTime createdAt;

  // Links to social media handles | සමාජ මාධ්‍ය ගිණුම් වෙත ඇති සබැඳි
  final List<String> socialLinks;

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
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

  // Converts verification enum to localized display text
  // සත්‍යාපන enum අගය දේශීයකරණය කළ ප්‍රදර්ශන පෙළක් බවට හරවන Getter එක
  String get verificationStatusText {
    switch (verificationStatus) {
      case OrganizerVerificationStatus.pending:
        return 'Pending Review'; // English | සමාලෝචනය අපේක්ෂිතයි (Sinhala)
      case OrganizerVerificationStatus.verified:
        return 'Verified'; // English | සත්‍යාපිතයි (Sinhala)
      case OrganizerVerificationStatus.rejected:
        return 'Rejected'; // English | ප්‍රතික්ෂේපිතයි (Sinhala)
      case OrganizerVerificationStatus.suspended:
        return 'Suspended'; // English | අත්හිටුවා ඇත (Sinhala)
    }
  }

  // Helper check if organizer is verified | සංවිධායක සත්‍යාපනය කර ඇත්දැයි පරීක්ෂා කිරීමේ Getter එක
  bool get isVerified => verificationStatus == OrganizerVerificationStatus.verified;

  // ─── Factory constructor from Firestore Map | Firestore Map එකකින් Factory Constructor එක ───
  // Converts raw Firestore document fields to an Organizer object.
  // Firestore හි අමු දත්ත ක්ෂේත්‍ර Organizer වස්තුවක් බවට පරිවර්තනය කරයි.
  factory Organizer.fromMap(Map<String, dynamic> data, String id) {
    // Parse status from string to enum | String අගයක් ලෙස ඇති තත්වය Enum එකක් බවට Parse කිරීම
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

    // Parse creation date Timestamp safely | නිර්මාණය කළ දිනය Timestamp එකකින් ආරක්ෂිතව Parse කිරීම
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    // Build and return Organizer entity | Organizer වස්තුව ගොඩනගා ආපසු ලබා දීම
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

  // ─── Convert Organizer to Map for Firestore | Firestore සඳහා Map එකකට පරිවර්තනය කිරීම ───
  // Serializes the object properties to map layout for DB save.
  // දත්ත සමුදායේ සුරැකීම සඳහා වස්තුවේ ගුණාංග Map එකක් බවට ශ්‍රේණිගත කරයි.
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
    'createdAt': FieldValue.serverTimestamp(), // Firestore timestamp | Firestore සේවාදායකයේ කාල මුද්‍රාව
    'socialLinks': socialLinks,
  };

  // ─── copyWith - Create a modified copy | වෙනස් කළ පිටපතක් සාදා ගැනීම ────────────────────
  // Returns a new instance with specified fields modified, preserving the rest.
  // ඉතිරි ක්ෂේත්‍ර නොවෙනස්ව තබා ගනිමින්, නිශ්චිත ක්ෂේත්‍ර පමණක් වෙනස් කළ නව වස්තුවක් ලබා දෙයි.
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
      email: email, // Email is immutable once set | Email එක සැකසූ පසු වෙනස් කළ නොහැක
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
