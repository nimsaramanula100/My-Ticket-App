// lib/services/mock_firestore_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// MockFirestoreService | ආදර්ශ Firestore සේවා පන්තිය
// A local mock database service that simulates Firestore behavior for testing.
// පරීක්ෂණ කටයුතු සඳහා Firestore ක්‍රියාකාරිත්වය අනුකරණය කරන දේශීය ආදර්ශ සේවා පන්තියකි.
// Uses delayed futures to mimic realistic internet network latency.
// යථාර්ථවාදී අන්තර්ජාල ප්‍රමාදයන් අනුකරණය කිරීමට ප්‍රමාද කළ Future වස්තූන් භාවිතා කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/user.dart' as user_model;

class MockFirestoreService {
  // ─── Mock Tickets Data | ආදර්ශ ප්‍රවේශපත්‍ර දත්ත ──────────────────────────────
  // In-memory list of events representing simulated Firestore documents.
  // Firestore ලේඛන නියෝජනය කරන මතකයේ රඳවාගත් ආදර්ශ සිදුවීම් ලැයිස්තුව.
  static final List<Ticket> _mockTickets = [
    Ticket(
      id: '1',
      eventName: 'Metallica Live Concert',
      eventDescription:
          'Experience the legendary Metallica performing their greatest hits live.',
      eventImage: 'https://via.placeholder.com/400x200?text=Metallica+Concert',
      venue: 'Colombo City Centre',
      eventDate: DateTime.now().add(const Duration(days: 30)),
      price: 5000.0,
      category: 'Concert',
      availableSeats: 150,
      organizer: 'Live Events Sri Lanka',
    ),
    Ticket(
      id: '2',
      eventName: 'Cricket: Sri Lanka vs India',
      eventDescription:
          'International cricket match between Sri Lanka and India at the Colombo Oval.',
      eventImage: 'https://via.placeholder.com/400x200?text=Cricket+Match',
      venue: 'Colombo Oval',
      eventDate: DateTime.now().add(const Duration(days: 15)),
      price: 2500.0,
      category: 'Sports',
      availableSeats: 500,
      organizer: 'Sri Lanka Cricket Board',
    ),
    Ticket(
      id: '3',
      eventName: 'Avatar 4: The Last Airbender',
      eventDescription:
          'The latest blockbuster sci-fi movie in stunning 4K resolution.',
      eventImage: 'https://via.placeholder.com/400x200?text=Avatar+4',
      venue: 'Cineplex Colombo',
      eventDate: DateTime.now().add(const Duration(days: 5)),
      price: 1200.0,
      category: 'Movie',
      availableSeats: 200,
      organizer: 'Cineplex Theaters',
    ),
    Ticket(
      id: '4',
      eventName: 'Hamlet - Shakespeare Live',
      eventDescription:
          'A classical theatrical performance of Shakespeare\'s Hamlet by the National Theatre Company.',
      eventImage: 'https://via.placeholder.com/400x200?text=Hamlet+Theater',
      venue: 'National Theatre, Colombo',
      eventDate: DateTime.now().add(const Duration(days: 20)),
      price: 1500.0,
      category: 'Theater',
      availableSeats: 100,
      organizer: 'National Theatre Company',
    ),
    Ticket(
      id: '5',
      eventName: 'The Weeknd Concert Tour',
      eventDescription:
          'The Weeknd performs tracks from his latest album - After Hours.',
      eventImage: 'https://via.placeholder.com/400x200?text=The+Weeknd',
      venue: 'Sugathadasa Stadium',
      eventDate: DateTime.now().add(const Duration(days: 45)),
      price: 7500.0,
      category: 'Concert',
      availableSeats: 300,
      organizer: 'Astro Tours',
    ),
    Ticket(
      id: '6',
      eventName: 'Comedy Night with Harsha',
      eventDescription:
          'Stand-up comedy show featuring popular comedian Harsha Wardhana.',
      eventImage: 'https://via.placeholder.com/400x200?text=Comedy+Night',
      venue: 'Hilton Colombo',
      eventDate: DateTime.now().add(const Duration(days: 10)),
      price: 1000.0,
      category: 'Theater',
      availableSeats: 250,
      organizer: 'Comedy Central Sri Lanka',
    ),
  ];

  // ─── getAllTickets: Fetch all mock tickets | සියලුම ආදර්ශ ප්‍රවේශපත්‍ර ලබා ගැනීම ───
  // Simulates fetching with a 500ms network delay.
  // මිලි තත්පර 500ක ජාල ප්‍රමාදයක් සමඟ සියලුම ප්‍රවේශපත්‍ර ලබා ගැනීම අනුකරණය කරයි.
  Future<List<Ticket>> getAllTickets() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    return _mockTickets;
  }

  // ─── getTicketsByCategory: Filter by category | කාණ්ඩය අනුව පෙරීම ─────────────────
  Future<List<Ticket>> getTicketsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTickets.where((ticket) => ticket.category == category).toList();
  }

  // ─── getTicket: Fetch one mock event | එක් ආදර්ශ සිදුවීමක් ලබා ගැනීම ──────────────
  Future<Ticket?> getTicket(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockTickets.firstWhere((ticket) => ticket.id == ticketId);
    } catch (e) {
      return null;
    }
  }

  // ─── addTicket: Append mock event | ආදර්ශ සිදුවීමක් ඇතුළත් කිරීම ───────────────────
  // Calculates next numeric ID and appends ticket to private memory list.
  // ඊළඟ අංකිත ID එක ගණනය කර දේශීය මතක ලැයිස්තුවට ප්‍රවේශපත්‍රය ඇතුළත් කරයි.
  Future<String> addTicket(Ticket ticket) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = (int.parse(_mockTickets.last.id) + 1).toString();
    _mockTickets.add(Ticket(
      id: newId,
      eventName: ticket.eventName,
      eventDescription: ticket.eventDescription,
      eventImage: ticket.eventImage,
      venue: ticket.venue,
      eventDate: ticket.eventDate,
      price: ticket.price,
      category: ticket.category,
      availableSeats: ticket.availableSeats,
      organizer: ticket.organizer,
    ));
    return newId;
  }

  // ─── updateTicket: Update mock event details | ආදර්ශ සිදුවීමක් යාවත්කාලීන කිරීම ───
  Future<void> updateTicket(String ticketId, Ticket ticket) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockTickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      _mockTickets[index] = Ticket(
        id: ticketId,
        eventName: ticket.eventName,
        eventDescription: ticket.eventDescription,
        eventImage: ticket.eventImage,
        venue: ticket.venue,
        eventDate: ticket.eventDate,
        price: ticket.price,
        category: ticket.category,
        availableSeats: ticket.availableSeats,
        organizer: ticket.organizer,
      );
    }
  }

  // ─── createBooking: Mock create booking | ආදර්ශ වෙන්කිරීමක් නිර්මාණය කිරීම ──────
  // Generates a mock booking ID string using the current timestamp.
  // වත්මන් කාල මුද්‍රාව භාවිතයෙන් ආදර්ශ වෙන්කිරීම් ID පෙළක් නිර්මාණය කරයි.
  Future<String> createBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'booking_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ─── getUserBookings: Mock list user bookings | පරිශීලකයාගේ වෙන්කිරීම් ලබා ගැනීම ──
  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // ─── getBooking: Mock retrieve single booking | එක් ආදර්ශ වෙන්කිරීමක් ලබා ගැනීම ───
  Future<Booking?> getBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  // ─── updateBookingStatus: Mock status update | වෙන්කිරීම් තත්වය යාවත්කාලීන කිරීම ──
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ─── createUserProfile: Mock user profile creation | පරිශීලක පැතිකඩක් සෑදීම ──────
  Future<void> createUserProfile(String userId, user_model.User user) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ─── getUserProfile: Mock user profile fetching | පරිශීලක පැතිකඩ ලබා ගැනීම ────────
  Future<user_model.User?> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  // ─── updateUserProfile: Mock update profile fields | පරිශීලක පැතිකඩ වෙනස් කිරීම ──
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
