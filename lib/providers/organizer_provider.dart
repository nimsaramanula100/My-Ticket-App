// lib/providers/organizer_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// OrganizerProvider | සංවිධායක ප්‍රොවයිඩර්
// Manages the state, events, and bookings specifically for organizers.
// සංවිධායකයින් සඳහා වන තත්ත්වයන්, සිදුවීම් සහ වෙන්කිරීම් කළමනාකරණය කරයි.
// Extends ChangeNotifier so any UI listening will automatically rebuild on state updates.
// ChangeNotifier භාවිතා කරමින් තත්වයන් වෙනස් වන විට UI ස්වයංක්‍රීයව යාවත්කාලීන කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/organizer.dart';
import '../models/ticket_type.dart';
import '../services/firestore_service.dart';

class OrganizerProvider extends ChangeNotifier {
  // Access Firestore operations helper | Firestore දත්ත සමුදාය මෙහෙයුම් සහකාර
  final FirestoreService _service = FirestoreService();

  // ─── Private State Variables | පුද්ගලික තත්ව විචල්‍යයන් ──────────────────────
  Organizer? _organizer;             // Organizer profile data | සංවිධායක පැතිකඩ දත්ත
  List<Ticket> _events = [];         // All events from organizer | සංවිධායකගේ සියලුම සිදුවීම්
  List<Booking> _recentBookings = []; // Recent bookings list | මෑතකාලීන වෙන්කිරීම් ලැයිස්තුව
  double _totalRevenue = 0;          // Accumulated revenue | උපයා ඇති මුළු ආදායම
  int _totalAttendees = 0;           // Confirmed attendees | සහභාගිවන්නන්ගේ මුළු ගණන
  bool _isLoading = false;           // Operation loading state | මෙහෙයුම ක්‍රියාත්මක වන තත්වය
  String? _error;                    // Last captured error message | අවසන් වරට ඇතිවූ දෝෂ පණිවිඩය
  StreamSubscription? _eventsSub;    // Events real-time subscription | සිදුවීම් සජීවී දත්ත දායකත්වය
  StreamSubscription? _bookingsSub;   // Bookings real-time subscription | වෙන්කිරීම් සජීවී දත්ත දායකත්වය

  // ─── Public Getters | පොදු Getters ─────────────────────────────────────────
  Organizer? get organizer => _organizer;
  List<Ticket> get events => _events;
  
  // Filter only published events | ප්‍රසිද්ධ කර ඇති සිදුවීම් පමණක් පෙරීම
  List<Ticket> get publishedEvents =>
      _events.where((e) => e.status == EventStatus.published).toList();
      
  // Filter only draft events | කෙටුම්පත් ලෙස පවතින සිදුවීම් පමණක් පෙරීම
  List<Ticket> get draftEvents =>
      _events.where((e) => e.status == EventStatus.draft).toList();
      
  List<Booking> get recentBookings => _recentBookings;
  double get totalRevenue => _totalRevenue;
  int get totalAttendees => _totalAttendees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalEventsCount => _events.length;
  int get publishedEventsCount => publishedEvents.length;

  // ─── initialize: Load all organizer details | සංවිධායක තොරතුරු ආරම්භ කිරීම ───
  // Fetches basic profile, listens to events, and queries aggregated revenue.
  // සංවිධායක පැතිකඩ ලබා ගැනීම, සිදුවීම් සජීවීව ශ්‍රවණය කිරීම සහ මුළු ආදායම ලබා ගැනීම සිදු කරයි.
  Future<void> initialize(String organizerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Fetch organizer profile | 1. සංවිධායක පැතිකඩ දත්ත ලබා ගැනීම
      _organizer = await _service.getOrganizer(organizerId);
      
      // 2. Setup real-time listeners | 2. සජීවී දත්ත සම්බන්ධතා සැකසීම
      _listenToEvents(organizerId);
      _listenToBookings(organizerId);
      
      // 3. Load initial revenue summary | 3. ආරම්භක ආදායම් සාරාංශය ලබා ගැනීම
      _totalRevenue = await _service.getOrganizerRevenue(organizerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── _listenToEvents: Real-time events stream | සජීවී සිදුවීම් ශ්‍රවණය කිරීම ─────
  // Listens to Firestore events collection updates.
  // Firestore හි සිදුවීම් වෙනස්වීම් සජීවීව ශ්‍රවණය කරයි.
  void _listenToEvents(String organizerId) {
    _eventsSub?.cancel(); // Cancel previous stream to prevent leaks | පෙර සජීවී දායකත්වය අවලංගු කරයි
    _eventsSub = _service.streamOrganizerEvents(organizerId).listen(
      (events) {
        _events = events;
        notifyListeners(); // Rebuild UI on data arrival | නව දත්ත ලැබුණු විට UI යාවත්කාලීන කරයි
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // ─── _listenToBookings: Real-time bookings stream | සජීවී වෙන්කිරීම් ශ්‍රවණය කිරීම ──
  // Listens to bookings, and aggregates calculations dynamically.
  // වෙන්කිරීම් වෙනස්වීම් ශ්‍රවණය කර ආදායම සහ සහභාගිවන්නන් ස්වයංක්‍රීයව ගණනය කරයි.
  void _listenToBookings(String organizerId) {
    _bookingsSub?.cancel(); // Cancel previous stream to prevent leaks | පෙර සජීවී දායකත්වය අවලංගු කරයි
    _bookingsSub = _service.streamOrganizerBookings(organizerId).listen(
      (bookings) {
        // Take the latest 20 bookings | මෑතකාලීන වෙන්කිරීම් 20ක් ලබා ගනී
        _recentBookings = bookings.take(20).toList();
        
        // Sum total quantities of paid bookings | ගෙවන ලද වෙන්කිරීම් වල ප්‍රවේශපත්‍ර එකතුව
        _totalAttendees = bookings.fold(0, (sum, b) => sum + (b.isPaid ? b.quantity : 0));
        
        // Sum total revenue of paid bookings | ගෙවන ලද වෙන්කිරීම් වල මුළු ආදායම් එකතුව
        _totalRevenue = bookings.fold(0.0, (sum, b) => sum + (b.isPaid ? b.totalPrice : 0));
        notifyListeners();
      },
    );
  }

  // ─── createEvent: Publish a new event | නව සිදුවීමක් නිර්මාණය කිරීම ───────────
  // Creates event document and adds ticket categories associated.
  // නව සිදුවීම් ලේඛනය සාදා ඊට අදාළ ප්‍රවේශපත්‍ර කාණ්ඩ දත්ත සමුදායට ඇතුළත් කරයි.
  Future<String?> createEvent(Ticket event, List<TicketType> ticketTypes) async {
    try {
      // Add main event and get ID | ප්‍රධාන සිදුවීම ඇතුළත් කර ඊට අදාළ ID එක ලබා ගනී
      final id = await _service.addEvent(event);
      
      // Save all ticket configurations in sub-collection
      // එම සිදුවීම යටතේ ඇති සියලුම ප්‍රවේශපත්‍ර මට්ටම් ඇතුළත් කරයි
      for (final type in ticketTypes) {
        final newType = TicketType(
          id: '',
          eventId: id,
          name: type.name,
          price: type.price,
          totalQuantity: type.totalQuantity,
          availableQuantity: type.totalQuantity,
          description: type.description,
          perks: type.perks,
          isActive: type.isActive,
        );
        await _service.addTicketType(id, newType);
      }
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ─── updateEvent: Update existing event details | සිදුවීම් තොරතුරු යාවත්කාලීන කිරීම ──
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

  // ─── deleteEvent: Permanently remove event | සිදුවීමක් සම්පූර්ණයෙන් මකා දැමීම ──────
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

  // ─── publishEvent: Publish draft event | සිදුවීමක් ප්‍රසිද්ධ කිරීම ────────────────
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

  // ─── unpublishEvent: Revert to draft | සිදුවීමක් කෙටුම්පතක් බවට පත් කිරීම ─────────
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

  // ─── checkInAttendee: Confirm check-in of ticket holder | සහභාගිවන්නා සත්‍යාපනය කිරීම ──
  // Updates booking status to 'checkedIn' in Firestore.
  // Firestore හි අදාළ වෙන්කිරීමේ තත්වය 'පැමිණ ඇත' (checkedIn) ලෙස යාවත්කාලීන කරයි.
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

  // ─── updateOrganizerProfile: Update settings | සංවිධායක පැතිකඩ වෙනස් කිරීම ────────
  Future<bool> updateOrganizerProfile(
      String organizerId, Map<String, dynamic> data) async {
    try {
      await _service.updateOrganizer(organizerId, data);
      // Reload profile properties locally | දේශීයව පවතින සංවිධායක දත්ත නැවත පූරණය කරයි
      _organizer = await _service.getOrganizer(organizerId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── clear: Clear all local state | දේශීය තත්වයන් මකා දැමීම ───────────────────────
  // Invoked on user sign out.
  // පරිශීලකයා ගිණුමෙන් ඉවත් වන විට ක්‍රියාත්මක වේ.
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

  // ─── dispose: Clean resources | සම්පත් නිදහස් කිරීම ──────────────────────────────
  @override
  void dispose() {
    _eventsSub?.cancel();
    _bookingsSub?.cancel();
    super.dispose();
  }
}
