// lib/models/booking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, paid, failed, cancelled, refunded, checkedIn }

class Booking {
  final String id;
  final String userId;
  final String ticketId;       // event id
  final String organizerId;
  final String eventName;
  final DateTime bookingDate;
  final int quantity;
  final double totalPrice;
  final BookingStatus status;
  final String paymentMethod;
  final String? paymentId;
  // Enhanced fields
  final String ticketTypeId;
  final String ticketTypeName;
  final String qrData;         // JSON string for QR code
  final bool checkedIn;
  final DateTime? checkedInAt;
  final String userEmail;
  final String userName;
  final String userPhone;

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
  })  : status = status ?? BookingStatus.pending,
        qrData = qrData ?? '';

  // ─── Legacy status string getter ───────────────────────────
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

  bool get isPaid => status == BookingStatus.paid || status == BookingStatus.checkedIn;
  bool get isCancellable =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    DateTime bookingDate;
    if (data['bookingDate'] is Timestamp) {
      bookingDate = (data['bookingDate'] as Timestamp).toDate();
    } else if (data['bookingDate'] is String) {
      bookingDate = DateTime.tryParse(data['bookingDate']) ?? DateTime.now();
    } else {
      bookingDate = DateTime.now();
    }

    DateTime? checkedInAt;
    if (data['checkedInAt'] is Timestamp) {
      checkedInAt = (data['checkedInAt'] as Timestamp).toDate();
    }

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

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'ticketId': ticketId,
    'organizerId': organizerId,
    'eventName': eventName,
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
