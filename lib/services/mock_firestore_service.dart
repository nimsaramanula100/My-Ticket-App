import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/user.dart' as user_model;

class MockFirestoreService {
  // Mock tickets data
  static final List<Ticket> _mockTickets = [
    Ticket(
      id: '1',
      eventName: 'Metallica Live Concert',
      eventDescription:
          'Experience the legendary Metallica performing their greatest hits live.',
      eventImage: 'https://via.placeholder.com/400x200?text=Metallica+Concert',
      venue: 'Colombo City Centre',
      eventDate: DateTime.now().add(const Duration(days: 30)),
      price: '5000',
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
      price: '2500',
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
      price: '1200',
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
      price: '1500',
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
      price: '7500',
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
      price: '1000',
      category: 'Theater',
      availableSeats: 250,
      organizer: 'Comedy Central Sri Lanka',
    ),
  ];

  // Get all tickets
  Future<List<Ticket>> getAllTickets() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    return _mockTickets;
  }

  // Get tickets by category
  Future<List<Ticket>> getTicketsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTickets.where((ticket) => ticket.category == category).toList();
  }

  // Get single ticket
  Future<Ticket?> getTicket(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockTickets.firstWhere((ticket) => ticket.id == ticketId);
    } catch (e) {
      return null;
    }
  }

  // Add ticket (mock)
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

  // Update ticket (mock)
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

  // Create booking
  Future<String> createBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'booking_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // Get booking details
  Future<Booking?> getBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Create user profile
  Future<void> createUserProfile(String userId, user_model.User user) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get user profile
  Future<user_model.User?> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
