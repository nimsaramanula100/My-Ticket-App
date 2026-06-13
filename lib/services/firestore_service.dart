import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/user.dart' as user_model;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== TICKET OPERATIONS ==========

  // Get all tickets
  Future<List<Ticket>> getAllTickets() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('tickets').get();
      return snapshot.docs
          .map((doc) =>
              Ticket.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching tickets: $e');
    }
  }

  // Get tickets by category
  Future<List<Ticket>> getTicketsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tickets')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) =>
              Ticket.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching tickets by category: $e');
    }
  }

  // Get single ticket
  Future<Ticket?> getTicket(String ticketId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('tickets').doc(ticketId).get();
      if (doc.exists) {
        return Ticket.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching ticket: $e');
    }
  }

  // Add ticket (Admin)
  Future<String> addTicket(Ticket ticket) async {
    try {
      DocumentReference doc =
          await _firestore.collection('tickets').add(ticket.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Error adding ticket: $e');
    }
  }

  // Update ticket (Admin)
  Future<void> updateTicket(String ticketId, Ticket ticket) async {
    try {
      await _firestore
          .collection('tickets')
          .doc(ticketId)
          .update(ticket.toMap());
    } catch (e) {
      throw Exception('Error updating ticket: $e');
    }
  }

  // ========== BOOKING OPERATIONS ==========

  // Create booking
  Future<String> createBooking(Booking booking) async {
    try {
      DocumentReference doc =
          await _firestore.collection('bookings').add(booking.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookingDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching user bookings: $e');
    }
  }

  // Get booking details
  Future<Booking?> getBooking(String bookingId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching booking: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Error updating booking: $e');
    }
  }

  // ========== USER OPERATIONS ==========

  // Create user profile
  Future<void> createUserProfile(String userId, user_model.User user) async {
    try {
      await _firestore.collection('users').doc(userId).set(user.toMap());
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('does not exist') ||
          msg.toLowerCase().contains('not_found') ||
          msg.toLowerCase().contains('not-found')) {
        // Firestore database not provisioned for this project — fallback to
        // Realtime Database so sign-up/profile still works for testing.
        final db = FirebaseDatabase.instance;
        await db.ref('users/$userId').set(user.toMap());
        return;
      }
      throw Exception('Error creating user profile: $e');
    }
  }

  // Get user profile
  Future<user_model.User?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return user_model.User.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('does not exist') ||
          msg.toLowerCase().contains('not_found') ||
          msg.toLowerCase().contains('not-found')) {
        // Firestore not provisioned — try Realtime Database path
        try {
          final db = FirebaseDatabase.instance;
          final snapshot = await db.ref('users/$userId').get();
          if (snapshot.exists) {
            final data = Map<String, dynamic>.from(snapshot.value as Map);
            return user_model.User.fromMap(data, userId);
          }
          return null;
        } catch (e2) {
          throw Exception('Error fetching user profile from RTDB: $e2');
        }
      }
      throw Exception('Error fetching user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // Get all users (admin)
  Future<List<user_model.User>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => user_model.User.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
