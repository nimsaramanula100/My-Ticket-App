// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../models/organizer.dart';
import '../models/ticket_type.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ════════════════════════════════════════════
  // EVENTS (was "tickets" collection)
  // ════════════════════════════════════════════

  /// Stream of all published events (real-time)
  Stream<List<Ticket>> streamPublishedEvents() {
    return _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList());
  }

  /// Stream of featured events
  Stream<List<Ticket>> streamFeaturedEvents() {
    return _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList());
  }

  /// Events by category
  Future<List<Ticket>> getEventsByCategory(String category) async {
    final snap = await _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .where('category', isEqualTo: category)
        .get();
    return snap.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
  }

  /// Search events by name (prefix search)
  Future<List<Ticket>> searchEvents(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return getAllPublishedEvents();
    final snap = await _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .get();
    return snap.docs
        .map((d) => Ticket.fromMap(d.data(), d.id))
        .where((t) =>
            t.eventName.toLowerCase().contains(q) ||
            t.venue.toLowerCase().contains(q) ||
            t.organizer.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q))
        .toList();
  }

  Future<List<Ticket>> getAllPublishedEvents() async {
    final snap = await _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .orderBy('eventDate')
        .get();
    return snap.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
  }

  /// Legacy support — also read from old 'tickets' collection
  Future<List<Ticket>> getAllTickets() async {
    final futures = await Future.wait([
      _db.collection('events').where('status', isEqualTo: 'published').get(),
      _db.collection('tickets').get(),
    ]);
    final events = futures[0].docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
    final legacy = futures[1].docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
    return [...events, ...legacy];
  }

  Future<Ticket?> getEvent(String id) async {
    // Try events first, fall back to legacy tickets
    var doc = await _db.collection('events').doc(id).get();
    if (!doc.exists) {
      doc = await _db.collection('tickets').doc(id).get();
    }
    if (!doc.exists) return null;
    return Ticket.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Legacy alias
  Future<Ticket?> getTicket(String id) => getEvent(id);

  Future<String> addEvent(Ticket event) async {
    final doc = await _db.collection('events').add(event.toMap());
    return doc.id;
  }

  /// Legacy alias
  Future<String> addTicket(Ticket ticket) => addEvent(ticket);

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _db.collection('events').doc(id).update(data);
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
  }

  Future<void> publishEvent(String id) => updateEvent(id, {'status': 'published'});
  Future<void> unpublishEvent(String id) => updateEvent(id, {'status': 'draft'});

  // ════════════════════════════════════════════
  // TICKET TYPES (sub-collection of events)
  // ════════════════════════════════════════════

  Future<List<TicketType>> getTicketTypes(String eventId) async {
    final snap = await _db
        .collection('events')
        .doc(eventId)
        .collection('ticket_types')
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map((d) => TicketType.fromMap(d.data(), d.id)).toList();
  }

  Future<String> addTicketType(String eventId, TicketType type) async {
    final doc = await _db
        .collection('events')
        .doc(eventId)
        .collection('ticket_types')
        .add(type.toMap());
    return doc.id;
  }

  Future<void> updateTicketType(
      String eventId, String typeId, Map<String, dynamic> data) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('ticket_types')
        .doc(typeId)
        .update(data);
  }

  // ════════════════════════════════════════════
  // BOOKINGS
  // ════════════════════════════════════════════

  Future<String> createBooking(Booking booking) async {
    final doc = await _db.collection('bookings').add(booking.toMap());
    return doc.id;
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final snap = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .get();
    return snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList();
  }

  Stream<List<Booking>> streamUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  /// Get bookings for a specific event (organizer use)
  Future<List<Booking>> getEventBookings(String eventId) async {
    final snap = await _db
        .collection('bookings')
        .where('ticketId', isEqualTo: eventId)
        .orderBy('bookingDate', descending: true)
        .get();
    return snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList();
  }

  Stream<List<Booking>> streamEventBookings(String eventId) {
    return _db
        .collection('bookings')
        .where('ticketId', isEqualTo: eventId)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  /// All bookings for an organizer across all their events
  Stream<List<Booking>> streamOrganizerBookings(String organizerId) {
    return _db
        .collection('bookings')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return null;
    return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  Future<void> checkInBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'checkedIn',
      'checkedIn': true,
      'checkedInAt': FieldValue.serverTimestamp(),
    });
  }

  // ════════════════════════════════════════════
  // USERS
  // ════════════════════════════════════════════

  Future<AppUser?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data() as Map<String, dynamic>, userId);
  }

  Future<void> createUserProfile(String userId, AppUser user) async {
    await _db.collection('users').doc(userId).set(user.toMap());
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  Future<List<AppUser>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList();
  }

  Future<void> toggleFavoriteEvent(String userId, String eventId, bool add) async {
    await _db.collection('users').doc(userId).update({
      'favoriteEventIds': add
          ? FieldValue.arrayUnion([eventId])
          : FieldValue.arrayRemove([eventId]),
    });
  }

  // ════════════════════════════════════════════
  // ORGANIZERS
  // ════════════════════════════════════════════

  Future<Organizer?> getOrganizer(String organizerId) async {
    final doc = await _db.collection('organizers').doc(organizerId).get();
    if (!doc.exists) return null;
    return Organizer.fromMap(doc.data() as Map<String, dynamic>, organizerId);
  }

  Future<Organizer?> getOrganizerByUserId(String userId) async {
    final snap = await _db
        .collection('organizers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Organizer.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Future<void> updateOrganizer(
      String organizerId, Map<String, dynamic> data) async {
    await _db.collection('organizers').doc(organizerId).update(data);
  }

  /// Organizer's events (stream)
  Stream<List<Ticket>> streamOrganizerEvents(String organizerId) {
    return _db
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList());
  }

  Future<List<Ticket>> getOrganizerEvents(String organizerId) async {
    final snap = await _db
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
  }

  // ════════════════════════════════════════════
  // ANALYTICS HELPERS
  // ════════════════════════════════════════════

  /// Total revenue for organizer
  Future<double> getOrganizerRevenue(String organizerId) async {
    final snap = await _db
        .collection('bookings')
        .where('organizerId', isEqualTo: organizerId)
        .where('status', whereIn: ['paid', 'checkedIn'])
        .get();
    double total = 0;
    for (final doc in snap.docs) {
      total += (doc.data()['totalPrice'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  /// Total confirmed attendees for an event
  Future<int> getEventAttendeeCount(String eventId) async {
    final snap = await _db
        .collection('bookings')
        .where('ticketId', isEqualTo: eventId)
        .where('status', whereIn: ['paid', 'checkedIn'])
        .get();
    int total = 0;
    for (final doc in snap.docs) {
      total += (doc.data()['quantity'] as num?)?.toInt() ?? 0;
    }
    return total;
  }
}
