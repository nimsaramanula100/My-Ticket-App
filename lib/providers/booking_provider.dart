// lib/providers/booking_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// BookingProvider | Booking Provider
// Manages the list of bookings for the currently logged-in user.
// දැනට ලොගින් වූ user ගේ booking ලැයිස්තුව කළමනාකරණය කරයි.
// Uses a real-time Firestore stream so the UI updates instantly on changes.
// UI instant ලෙස update වීමට real-time Firestore stream භාවිතා කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';

// ─── BookingProvider Class ────────────────────────────────────────────────────
class BookingProvider extends ChangeNotifier {
  // Uses FirestoreService to read/write Firestore data
  // Firestore data කියවීමට/ලිවීමට FirestoreService භාවිතා කරයි
  final FirestoreService _service = FirestoreService();

  // Internal state variables | Internal state variables
  List<Booking> _bookings = [];   // All bookings for the current user | වත්මන් user ගේ සියලු bookings
  bool _isLoading = false;        // True while loading | Loading වන විට true
  String? _error;                 // Last error message | අවසාන error message
  StreamSubscription? _sub;       // Active Firestore stream subscription | Active stream subscription

  // ─── Public getters | Public getters ─────────────────────────────────────────

  // All bookings for this user | මෙම user ගේ සියලු bookings
  List<Booking> get bookings => _bookings;

  // Upcoming paid bookings (events that haven't ended yet)
  // ඉදිරි ගෙවූ bookings (තවමත් ඉවර නොවූ සිදුවීම්)
  // Uses a 2-hour grace period so recently ended events still appear
  // පසුගිය 2 පැය තුළ සිදු වූ events ද පෙනෙන ලෙස 2-hour grace period භාවිතා කරයි
  List<Booking> get upcomingBookings => _bookings
      .where((b) => b.isPaid && b.bookingDate.isAfter(
          DateTime.now().subtract(const Duration(hours: 2))))
      .toList();

  // Past bookings (all bookings NOT in the upcoming list)
  // පසු bookings (upcoming ලැයිස්තුවේ නොමැති සියලු bookings)
  List<Booking> get pastBookings => _bookings
      .where((b) => !upcomingBookings.contains(b))
      .toList();

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── loadUserBookings: Start streaming bookings for a user ───────────────────
  // Cancels any previous stream and starts a new one for this userId.
  // කිසියම් කලින් stream cancel කර, මෙම userId සඳහා නව stream ආරම්භ කරයි.
  void loadUserBookings(String userId) {
    // Cancel previous subscription to prevent memory leaks
    // Memory leaks වළකීමට කලින් subscription cancel කරයි
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    // Start listening to the Firestore real-time stream
    // Firestore real-time stream listen කිරීම ආරම්භ කරයි
    _sub = _service.streamUserBookings(userId).listen(
      (bookings) {
        // New data arrived — update the list and notify listeners
        // නව data ලැබුණා — ලැයිස්තුව යාවත්කාලීන කර listeners ට දන්වයි
        _bookings = bookings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        // Stream emitted an error — store it and stop loading
        // Stream error emit කළා — error ගබඩා කර loading නිවා දමයි
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ─── createBooking: Save a new booking to Firestore ──────────────────────────
  // Returns the new document ID on success, or null if an error occurred.
  // සාර්ථකව ගෙවූ විට නව document ID, error ඇති විට null ලබා දෙයි.
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

  // ─── updateStatus: Update the status field of a booking ──────────────────────
  // e.g., change from 'pending' to 'paid' after successful payment.
  // e.g., ගෙවීම සාර්ථකව ව්ද පසු 'pending' සිට 'paid' ලෙස වෙනස් කිරීම.
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

  // ─── clear: Reset bookings when the user signs out ───────────────────────────
  // Cancels the stream and clears all local booking data.
  // User sign out කළ විට stream cancel කර local booking data ඉවත් කරයි.
  void clear() {
    _sub?.cancel();
    _bookings = [];
    _error = null;
    notifyListeners();
  }

  // ─── dispose: Clean up resources when the provider is destroyed ──────────────
  // Always cancel streams to prevent memory leaks.
  // Memory leaks වළකීමට සැමවිටම streams cancel කරයි.
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
