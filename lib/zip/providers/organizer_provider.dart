// lib/providers/organizer_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/organizer.dart';
import '../services/firestore_service.dart';

class OrganizerProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  Organizer? _organizer;
  List<Ticket> _events = [];
  List<Booking> _recentBookings = [];
  double _totalRevenue = 0;
  int _totalAttendees = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _eventsSub;
  StreamSubscription? _bookingsSub;

  Organizer? get organizer => _organizer;
  List<Ticket> get events => _events;
  List<Ticket> get publishedEvents =>
      _events.where((e) => e.status == EventStatus.published).toList();
  List<Ticket> get draftEvents =>
      _events.where((e) => e.status == EventStatus.draft).toList();
  List<Booking> get recentBookings => _recentBookings;
  double get totalRevenue => _totalRevenue;
  int get totalAttendees => _totalAttendees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalEventsCount => _events.length;
  int get publishedEventsCount => publishedEvents.length;

  Future<void> initialize(String organizerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _organizer = await _service.getOrganizer(organizerId);
      _listenToEvents(organizerId);
      _listenToBookings(organizerId);
      _totalRevenue = await _service.getOrganizerRevenue(organizerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToEvents(String organizerId) {
    _eventsSub?.cancel();
    _eventsSub = _service.streamOrganizerEvents(organizerId).listen(
      (events) {
        _events = events;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void _listenToBookings(String organizerId) {
    _bookingsSub?.cancel();
    _bookingsSub = _service.streamOrganizerBookings(organizerId).listen(
      (bookings) {
        _recentBookings = bookings.take(20).toList();
        _totalAttendees = bookings.fold(0, (sum, b) => sum + (b.isPaid ? b.quantity : 0));
        _totalRevenue = bookings.fold(0.0, (sum, b) => sum + (b.isPaid ? b.totalPrice : 0));
        notifyListeners();
      },
    );
  }

  Future<String?> createEvent(Ticket event) async {
    try {
      final id = await _service.addEvent(event);
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _service.updateEvent(eventId, data);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _service.deleteEvent(eventId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> publishEvent(String eventId) async {
    try {
      await _service.publishEvent(eventId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unpublishEvent(String eventId) async {
    try {
      await _service.unpublishEvent(eventId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkInAttendee(String bookingId) async {
    try {
      await _service.checkInBooking(bookingId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrganizerProfile(
      String organizerId, Map<String, dynamic> data) async {
    try {
      await _service.updateOrganizer(organizerId, data);
      _organizer = await _service.getOrganizer(organizerId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _eventsSub?.cancel();
    _bookingsSub?.cancel();
    _organizer = null;
    _events = [];
    _recentBookings = [];
    _totalRevenue = 0;
    _totalAttendees = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _bookingsSub?.cancel();
    super.dispose();
  }
}
