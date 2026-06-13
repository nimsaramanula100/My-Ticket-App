class Ticket {
  final String id;
  final String eventName;
  final String eventDescription;
  final String eventImage;
  final String venue;
  final DateTime eventDate;
  final String price;
  final String category;
  final int availableSeats;
  final String organizer;

  Ticket({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    required this.eventImage,
    required this.venue,
    required this.eventDate,
    required this.price,
    required this.category,
    required this.availableSeats,
    required this.organizer,
  });

  factory Ticket.fromMap(Map<String, dynamic> data, String docId) {
    return Ticket(
      id: docId,
      eventName: data['eventName'] ?? '',
      eventDescription: data['eventDescription'] ?? '',
      eventImage: data['eventImage'] ?? '',
      venue: data['venue'] ?? '',
      eventDate: data['eventDate'] != null
          ? DateTime.parse(data['eventDate'])
          : DateTime.now(),
      price: data['price'] ?? '0',
      category: data['category'] ?? 'General',
      availableSeats: data['availableSeats'] ?? 0,
      organizer: data['organizer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventImage': eventImage,
      'venue': venue,
      'eventDate': eventDate.toIso8601String(),
      'price': price,
      'category': category,
      'availableSeats': availableSeats,
      'organizer': organizer,
    };
  }
}
