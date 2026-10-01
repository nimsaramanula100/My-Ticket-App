// lib/models/booking.dart
// ─────────────────────────────────────────────────────────────────────────────
// Booking Model | බුකිං ආකෘතිය
// This file defines the Booking data model and its status types.
// මෙම ගොනුව Booking දත්ත ආකෘතිය සහ එහි තත්ව වර්ග නිර්වචනය කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for all possible booking statuses
// හැකි සියලු booking තත්ව සඳහා Enum (කල්බලය, තහවුරු, ගෙවීම, ...)
enum BookingStatus { pending, confirmed, paid, failed, cancelled, refunded, checkedIn }

// ─── Booking Class | Booking පන්තිය ───────────────────────────────────────────
// Represents a single ticket booking made by a user.
// පරිශීලකයෙකු විසින් කරන ලද එකම ticket booking එකක් නිරූපණය කරයි.
class Booking {
  // Unique document ID in Firestore | Firestore හි අද්විතීය ID
  final String id;

  // The UID of the user who booked | Booking කළ පරිශීලකයාගේ UID
  final String userId;

  // The event/ticket document ID | සිදුවීමේ/ticket ලේඛන ID
  final String ticketId;       // event id

  // The organizer's ID linked to this event | සිදුවීමට සම්බන්ධ organizer ID
  final String organizerId;

  // Display name of the event | සිදුවීමේ නම
  final String eventName;

  // The date/time when the booking was made | Booking කළ දිනය/වේලාව
  final DateTime bookingDate;

  // Number of tickets booked | Book කළ ticket ගණන
  final int quantity;

  // Total amount paid | ගෙවූ මුළු මුදල
  final double totalPrice;

  // Current status of the booking | Booking හි වර්තමාන තත්වය
  final BookingStatus status;

  // Payment method used (razorpay, demo, etc.) | භාවිතා කළ ගෙවීම් ක්‍රමය
  final String paymentMethod;

  // Payment transaction ID (optional) | ගෙවීම් ගනුදෙනු ID (අවශ්‍ය නොවිය හැකි)
  final String? paymentId;

  // ─── Enhanced/Additional Fields | වැඩිදියුණු කළ ක්ෂේත්‍ර ───────────────────
  // The ticket type ID (e.g. VIP, General) | Ticket වර්ගයේ ID
  final String ticketTypeId;

  // The name of the ticket type | Ticket වර්ගයේ නම
  final String ticketTypeName;

  // JSON string used to generate the QR code | QR code සාදීමට JSON string
  final String qrData;         // JSON string for QR code

  // Whether the attendee has checked in | සහභාගිවෙන්නා check-in කළාද
  final bool checkedIn;

  // When the attendee checked in (null if not checked in) | Check-in කළ වේලාව (check-in නොකළොත් null)
  final DateTime? checkedInAt;

  // Email address of the user | පරිශීලකයාගේ ඊමේල් ලිපිනය
  final String userEmail;

  // Display name of the user | පරිශීලකයාගේ නම
  final String userName;

  // Phone number of the user | පරිශීලකයාගේ දුරකථන අංකය
  final String userPhone;

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
  Booking({
    required this.id,
    required this.userId,
    required this.ticketId,
    this.organizerId = '',
    required this.eventName,
    required this.bookingDate,
    required this.quantity,
    required this.totalPrice,
    BookingStatus? status,
    this.paymentMethod = 'razorpay',
    this.paymentId,
    this.ticketTypeId = '',
    this.ticketTypeName = 'Regular',
    String? qrData,
    this.checkedIn = false,
    this.checkedInAt,
    this.userEmail = '',
    this.userName = '',
    this.userPhone = '',
  // Default status is 'pending' if not provided | සපයා නොදෙනු ලැබුවහොත් default status 'pending' වේ
  })  : status = status ?? BookingStatus.pending,
        qrData = qrData ?? '';

  // ─── Status text getter | තත්ව පෙළ getter ────────────────────────────────────
  // Returns the string version of the status for Firestore storage.
  // Firestore ගබඩා කිරීම සඳහා status හි string අනුවාදය ලබා දෙයි.
  String get statusText {
    switch (status) {
      case BookingStatus.pending: return 'pending';
      case BookingStatus.confirmed: return 'confirmed';
      case BookingStatus.paid: return 'paid';
      case BookingStatus.failed: return 'failed';
      case BookingStatus.cancelled: return 'cancelled';
      case BookingStatus.refunded: return 'refunded';
      case BookingStatus.checkedIn: return 'checkedIn';
    }
  }

  // Returns true if the booking is paid or the user has checked in
  // Booking ගෙවා ඇත්නම් හෝ check-in කළ ඇත්නම් true ලබා දෙයි
  bool get isPaid => status == BookingStatus.paid || status == BookingStatus.checkedIn;

  // Returns true if the booking can be cancelled
  // Booking අවලංගු කළ හැකිනම් true ලබා දෙයි
  bool get isCancellable =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  // ─── Factory constructor from Firestore Map | Firestore Map වලින් factory constructor ───
  // Converts raw Firestore document data into a Booking object.
  // Firestore ලේඛන දත්ත Booking object බවට පරිවර්තනය කරයි.
  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    // Parse bookingDate from Firestore Timestamp or String
    // Firestore Timestamp හෝ String වලින් bookingDate parse කරයි
    DateTime bookingDate;
    if (data['bookingDate'] is Timestamp) {
      bookingDate = (data['bookingDate'] as Timestamp).toDate();
    } else if (data['bookingDate'] is String) {
      bookingDate = DateTime.tryParse(data['bookingDate']) ?? DateTime.now();
    } else {
      bookingDate = DateTime.now();
    }

    // Parse checkedInAt timestamp if available
    // checkedInAt timestamp ලබා ගත හැකිනම් parse කරයි
    DateTime? checkedInAt;
    if (data['checkedInAt'] is Timestamp) {
      checkedInAt = (data['checkedInAt'] as Timestamp).toDate();
    }

    // Convert string status to enum value
    // string status enum value බවට පරිවර්තනය කරයි
    BookingStatus status;
    switch (data['status']) {
      case 'confirmed': status = BookingStatus.confirmed; break;
      case 'paid': status = BookingStatus.paid; break;
      case 'failed': status = BookingStatus.failed; break;
      case 'cancelled': status = BookingStatus.cancelled; break;
      case 'refunded': status = BookingStatus.refunded; break;
      case 'checkedIn': status = BookingStatus.checkedIn; break;
      default: status = BookingStatus.pending;
    }

    // Build and return the Booking object
    // Booking object ගොඩනගා ලබා දෙයි
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      ticketId: data['ticketId'] ?? data['eventId'] ?? '',
      organizerId: data['organizerId'] ?? '',
      eventName: data['eventName'] ?? '',
      bookingDate: bookingDate,
      quantity: data['quantity'] ?? 1,
      totalPrice: double.tryParse(data['totalPrice'].toString()) ?? 0.0,
      status: status,
      paymentMethod: data['paymentMethod'] ?? 'razorpay',
      paymentId: data['paymentId'],
      ticketTypeId: data['ticketTypeId'] ?? '',
      ticketTypeName: data['ticketTypeName'] ?? 'Regular',
      qrData: data['qrData'] ?? '',
      checkedIn: data['checkedIn'] ?? false,
      checkedInAt: checkedInAt,
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
    );
  }

  // ─── Convert Booking to Map for saving to Firestore | Firestore හි සුරැකීමට Map බවට ───
  // Converts the Booking object into a key-value map.
  // Booking object key-value map එකක් බවට පරිවර්තනය කරයි.
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'ticketId': ticketId,
    'organizerId': organizerId,
    'eventName': eventName,
    // Use server timestamp to avoid clock differences | Clock වෙනස්කම් වළකීමට server timestamp භාවිතා කරයි
    'bookingDate': FieldValue.serverTimestamp(),
    'quantity': quantity,
    'totalPrice': totalPrice,
    'status': statusText,
    'paymentMethod': paymentMethod,
    'paymentId': paymentId,
    'ticketTypeId': ticketTypeId,
    'ticketTypeName': ticketTypeName,
    'qrData': qrData,
    'checkedIn': checkedIn,
    'checkedInAt': checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
    'userEmail': userEmail,
    'userName': userName,
    'userPhone': userPhone,
  };
}
