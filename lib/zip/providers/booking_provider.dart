// lib/providers/booking_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _sub;

  List<Booking> get bookings => _bookings;
  List<Booking> get upcomingBookings => _bookings
      .where((b) => b.isPaid && b.bookingDate.isAfter(
          DateTime.now().subtract(const Duration(hours: 2))))
      .toList();
  List<Booking> get pastBookings => _bookings
      .where((b) => !upcomingBookings.contains(b))
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadUserBookings(String userId) {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    _sub = _service.streamUserBookings(userId).listen(
      (bookings) {
        _bookings = bookings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<String?> createBooking(Booking booking) async {
    try {
      final id = await _service.createBooking(booking);
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStatus(String bookingId, String status) async {
    try {
      await _service.updateBookingStatus(bookingId, status);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _sub?.cancel();
    _bookings = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
