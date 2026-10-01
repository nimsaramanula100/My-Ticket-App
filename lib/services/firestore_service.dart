// lib/services/firestore_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// FirestoreService | Firestore සේවා පන්තිය
// Handles all CRUD operations, streams, and queries on Cloud Firestore.
// Cloud Firestore හි සියලුම CRUD මෙහෙයුම්, සජීවී දත්ත සහ සෙවීම් හසුරුවයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../models/organizer.dart';
import '../models/ticket_type.dart';

class FirestoreService {
  // Main Firestore database instance | Firestore දත්ත සමුදායේ ප්‍රධාන වස්තුව
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ════════════════════════════════════════════════════════════════════════════
  // EVENTS SECTIONS | සිදුවීම් අංශය (was "tickets" collection)
  // ════════════════════════════════════════════════════════════════════════════

  // Stream of all published events (real-time)
  // ප්‍රසිද්ධ කළ සියලුම සිදුවීම් සජීවීව ලබා දෙන දත්ත ප්‍රවාහය (real-time)
  Stream<List<Ticket>> streamPublishedEvents() {
    return _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList());
  }

  // Stream of published featured events
  // විශේෂිත ලෙස නම්කර ඇති සක්‍රීය සිදුවීම් සජීවීව ලබා දෙන දත්ත ප්‍රවාහය
  Stream<List<Ticket>> streamFeaturedEvents() {
    return _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList());
  }

  // Retrieve events matching a specific category
  // යම් නිශ්චිත කාණ්ඩයකට අයත් සිදුවීම් ලබා ගැනීම
  Future<List<Ticket>> getEventsByCategory(String category) async {
    final snap = await _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .where('category', isEqualTo: category)
        .get();
    return snap.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
  }

  // Search events locally on fields after fetching published ones
  // ප්‍රසිද්ධ කළ සිදුවීම් ලබාගෙන දේශීයව ඒවායේ නම, ස්ථානය හෝ නගරය අනුව සෙවීම
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

  // Get all active events sorted by date
  // දිනය අනුව පෙළගස්වන ලද සියලුම සක්‍රීය සිදුවීම් ලැයිස්තුව ලබා ගැනීම
  Future<List<Ticket>> getAllPublishedEvents() async {
    final snap = await _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .orderBy('eventDate')
        .get();
    return snap.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
  }

  // Legacy support - merges events and legacy tickets collections
  // පැරණි කේතයන්ගේ සහාය සඳහා පැරණි tickets එකතුව සහ නව events එකතුව ඒකාබද්ධ කර ලබා ගැනීම
  Future<List<Ticket>> getAllTickets() async {
    final futures = await Future.wait([
      _db.collection('events').where('status', isEqualTo: 'published').get(),
      _db.collection('tickets').get(),
    ]);
    final events = futures[0].docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
    final legacy = futures[1].docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
    return [...events, ...legacy];
  }

  // Fetch event document by ID, checking events first then legacy tickets collection
  // ID එක මඟින් සිදුවීමක් ලබා ගැනීම (පළමුව events එකතුවද, නැතහොත් පැරණි tickets එකතුවද පරීක්ෂා කරයි)
  Future<Ticket?> getEvent(String id) async {
    var doc = await _db.collection('events').doc(id).get();
    if (!doc.exists) {
      doc = await _db.collection('tickets').doc(id).get();
    }
    if (!doc.exists) return null;
    return Ticket.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Legacy alias for getEvent | getEvent සඳහා පැරණි අන්වර්ථ නාමය
  Future<Ticket?> getTicket(String id) => getEvent(id);

  // Add a new event or set it with predefined ID if provided
  // නව සිදුවීමක් දත්ත සමුදායට එක් කිරීම (ID එකක් තිබේ නම් එය යොදාගෙන ලියයි)
  Future<String> addEvent(Ticket event) async {
    if (event.id.isNotEmpty) {
      await _db.collection('events').doc(event.id).set(event.toMap());
      return event.id;
    }
    final doc = await _db.collection('events').add(event.toMap());
    return doc.id;
  }

  // Legacy alias for addEvent | addEvent සඳහා පැරණි අන්වර්ථ නාමය
  Future<String> addTicket(Ticket ticket) => addEvent(ticket);

  // Update specific fields of an event | සිදුවීමක නිශ්චිත ක්ෂේත්‍ර යාවත්කාලීන කිරීම
  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _db.collection('events').doc(id).update(data);
  }

  // Delete event document | සිදුවීම් ලේඛනය දත්ත සමුදායෙන් මකා දැමීම
  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
  }

  // Publish event (change status to 'published') | සිදුවීමක් ප්‍රසිද්ධ කිරීම
  Future<void> publishEvent(String id) => updateEvent(id, {'status': 'published'});
  
  // Revert event to draft status | සිදුවීමක ප්‍රසිද්ධිය ඉවත් කර කෙටුම්පතක් බවට පත්කිරීම
  Future<void> unpublishEvent(String id) => updateEvent(id, {'status': 'draft'});

  // ════════════════════════════════════════════════════════════════════════════
  // TICKET TYPES (sub-collection of events) | ප්‍රවේශපත්‍ර මට්ටම් (සිදුවීම් වල අනු එකතුවක්)
  // ════════════════════════════════════════════════════════════════════════════

  // Get active pricing tiers for a specific event
  // යම් සිදුවීමකට අදාළ සියලුම සක්‍රීය ප්‍රවේශපත්‍ර මිල මට්ටම් ලබා ගැනීම
  Future<List<TicketType>> getTicketTypes(String eventId) async {
    final snap = await _db
        .collection('events')
        .doc(eventId)
        .collection('ticket_types')
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map((d) => TicketType.fromMap(d.data(), d.id)).toList();
  }

  // Add a ticket pricing tier under an event's subcollection
  // සිදුවීමක් යටතේ නව ප්‍රවේශපත්‍ර මිල මට්ටමක් ඇතුළත් කිරීම
  Future<String> addTicketType(String eventId, TicketType type) async {
    final doc = await _db
        .collection('events')
        .doc(eventId)
        .collection('ticket_types')
        .add(type.toMap());
    return doc.id;
  }

  // Update details of a specific ticket pricing tier
  // අදාළ ප්‍රවේශපත්‍ර මිල මට්ටමක විස්තර යාවත්කාලීන කිරීම
  Future<void> updateTicketType(
      String eventId, String typeId, Map<String, dynamic> data) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('ticket_types')
        .doc(typeId)
        .update(data);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BOOKINGS | ප්‍රවේශපත්‍ර වෙන්කිරීම්
  // ════════════════════════════════════════════════════════════════════════════

  // Create a new booking document | නව වෙන්කිරීමක් දත්ත සමුදායට එක් කිරීම
  Future<String> createBooking(Booking booking) async {
    final doc = await _db.collection('bookings').add(booking.toMap());
    return doc.id;
  }

  // Get all bookings of a user by UID | පරිශීලකයාගේ සියලුම වෙන්කිරීම් ලැයිස්තුව ලබා ගැනීම
  Future<List<Booking>> getUserBookings(String userId) async {
    final snap = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .get();
    return snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList();
  }

  // Real-time stream of a user's bookings | පරිශීලකයෙකුගේ වෙන්කිරීම් සජීවීව නිරීක්ෂණය කරන දත්ත ප්‍රවාහය
  Stream<List<Booking>> streamUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  // Get bookings for an event (primarily for organizer use)
  // යම් සිදුවීමකට අදාළ සියලුම වෙන්කිරීම් ලබා ගැනීම (සංවිධායකයින් සඳහා)
  Future<List<Booking>> getEventBookings(String eventId) async {
    final snap = await _db
        .collection('bookings')
        .where('ticketId', isEqualTo: eventId)
        .orderBy('bookingDate', descending: true)
        .get();
    return snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList();
  }

  // Stream bookings for an event | යම් සිදුවීමක වෙන්කිරීම් සජීවීව නිරීක්ෂණය කිරීම
  Stream<List<Booking>> streamEventBookings(String eventId) {
    return _db
        .collection('bookings')
        .where('ticketId', isEqualTo: eventId)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  // Stream all bookings across all events managed by an organizer
  // සංවිධායකවරයෙකුගේ සියලුම සිදුවීම් සඳහා ලැබෙන වෙන්කිරීම් සජීවීව නිරීක්ෂණය කිරීම
  Stream<List<Booking>> streamOrganizerBookings(String organizerId) {
    return _db
        .collection('bookings')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  // Retrieve details of a single booking by ID | ID එක මඟින් වෙන්කිරීමක විස්තර ලබා ගැනීම
  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return null;
    return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Change the status of a booking document | වෙන්කිරීමක තත්වය යාවත්කාලීන කිරීම (e.g. pending -> paid)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  // Check-in a booking, marking checkedIn=true and recording server time
  // සහභාගිවන්නෙකු පැමිණ ඇති බව සලකුණු කිරීම සහ පැමිණි වේලාව සේවාදායකයේ සටහන් කිරීම
  Future<void> checkInBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'checkedIn',
      'checkedIn': true,
      'checkedInAt': FieldValue.serverTimestamp(),
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // USERS | පරිශීලකයින්
  // ════════════════════════════════════════════════════════════════════════════

  // Get user profile information by UID | පරිශීලක පැතිකඩ තොරතුරු ලබා ගැනීම
  Future<AppUser?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data() as Map<String, dynamic>, userId);
  }

  // Create a new user profile record | නව පරිශීලක පැතිකඩක් දත්ත සමුදායේ නිර්මාණය කිරීම
  Future<void> createUserProfile(String userId, AppUser user) async {
    await _db.collection('users').doc(userId).set(user.toMap());
  }

  // Update existing user profile properties | පවතින පරිශීලක පැතිකඩ තොරතුරු යාවත්කාලීන කිරීම
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // Fetch all registered users in the database | පද්ධතියේ ලියාපදිංචි සියලුම පරිශීලකයින් ලබා ගැනීම
  Future<List<AppUser>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList();
  }

  // Add or remove an event ID from user's favoriteEvents list
  // පරිශීලකයෙකුගේ ප්‍රියතම සිදුවීම් ලැයිස්තුවට සිදුවීමක් එක් කිරීම හෝ ඉවත් කිරීම
  Future<void> toggleFavoriteEvent(String userId, String eventId, bool add) async {
    await _db.collection('users').doc(userId).update({
      'favoriteEventIds': add
          ? FieldValue.arrayUnion([eventId])
          : FieldValue.arrayRemove([eventId]),
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ORGANIZERS | සංවිධායකයින්
  // ════════════════════════════════════════════════════════════════════════════

  // Get organizer profile details | සංවිධායක පැතිකඩ විස්තර ලබා ගැනීම
  Future<Organizer?> getOrganizer(String organizerId) async {
    final doc = await _db.collection('organizers').doc(organizerId).get();
    if (!doc.exists) return null;
    return Organizer.fromMap(doc.data() as Map<String, dynamic>, organizerId);
  }

  // Query organizer profile by linked user account UID
  // සම්බන්ධිත පරිශීලක ගිණුමේ UID එක මඟින් සංවිධායක පැතිකඩ ලබා ගැනීම
  Future<Organizer?> getOrganizerByUserId(String userId) async {
    final snap = await _db
        .collection('organizers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Organizer.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  // Update organizer settings | සංවිධායක පැතිකඩෙහි විස්තර යාවත්කාලීන කිරීම
  Future<void> updateOrganizer(
      String organizerId, Map<String, dynamic> data) async {
    await _db.collection('organizers').doc(organizerId).update(data);
  }

  // Stream events published by a specific organizer
  // යම් සංවිධායකවරයෙකු පළකර ඇති සියලුම සිදුවීම් සජීවීව නිරීක්ෂණය කිරීම
  Stream<List<Ticket>> streamOrganizerEvents(String organizerId) {
    return _db
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList());
  }

  // Fetch static list of events published by an organizer
  // සංවිධායකවරයෙකු පළකර ඇති සියලුම සිදුවීම් ස්ථිතික ලැයිස්තුවක් ලෙස ලබා ගැනීම
  Future<List<Ticket>> getOrganizerEvents(String organizerId) async {
    final snap = await _db
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ANALYTICS HELPERS | විශ්ලේෂණ සහකාර ශ්‍රිත
  // ════════════════════════════════════════════════════════════════════════════

  // Aggregates total revenue of paid bookings for an organizer
  // සංවිධායකවරයෙකුගේ ගෙවන ලද සියලුම වෙන්කිරීම් වල මුළු ආදායම ගණනය කර ලබා ගැනීම
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

  // Count aggregate quantities of paid tickets for a single event
  // එක් සිදුවීමක් සඳහා විකිණී ඇති මුළු ප්‍රවේශපත්‍ර සංඛ්‍යාව ගණනය කිරීම
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
