// lib/models/ticket.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ticket_type.dart';

enum EventStatus { draft, published, soldOut, ended, cancelled }

class Ticket {
  final String id;
  final String eventName;
  final String eventDescription;
  final String eventImage;
  final String venue;
  final DateTime eventDate;
  final DateTime? eventEndDate;
  final double price;          // Base/minimum price
  final String category;
  final int availableSeats;
  final int totalSeats;
  final String organizer;
  final String organizerId;
  final EventStatus status;
  final bool isFeatured;
  final List<String> tags;
  final List<TicketType> ticketTypes;
  final String city;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  Ticket({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    required this.eventImage,
    required this.venue,
    required this.eventDate,
    this.eventEndDate,
    required this.price,
    required this.category,
    required this.availableSeats,
    int? totalSeats,
    required this.organizer,
    this.organizerId = '',
    this.status = EventStatus.published,
    this.isFeatured = false,
    this.tags = const [],
    this.ticketTypes = const [],
    this.city = 'Colombo',
    this.latitude,
    this.longitude,
    this.createdAt,
  }) : totalSeats = totalSeats ?? availableSeats;

  // ─── Getters (backwards compatibility) ──────────────────────
  String get title => eventName;
  String get description => eventDescription;
  String get imageUrl => eventImage;

  bool get isPublished => status == EventStatus.published;
  bool get isSoldOut => availableSeats <= 0 || status == EventStatus.soldOut;
  bool get isEnded => status == EventStatus.ended || eventDate.isBefore(DateTime.now());

  double get soldPercentage =>
      totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;

  String get statusText {
    switch (status) {
      case EventStatus.draft: return 'Draft';
      case EventStatus.published: return 'Published';
      case EventStatus.soldOut: return 'Sold Out';
      case EventStatus.ended: return 'Ended';
      case EventStatus.cancelled: return 'Cancelled';
    }
  }

  factory Ticket.fromMap(Map<String, dynamic> data, String id) {
    DateTime parsedDate;
    if (data['eventDate'] != null) {
      if (data['eventDate'] is Timestamp) {
        parsedDate = (data['eventDate'] as Timestamp).toDate();
      } else if (data['eventDate'] is String) {
        parsedDate = DateTime.tryParse(data['eventDate']) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? endDate;
    if (data['eventEndDate'] != null) {
      if (data['eventEndDate'] is Timestamp) {
        endDate = (data['eventEndDate'] as Timestamp).toDate();
      } else if (data['eventEndDate'] is String) {
        endDate = DateTime.tryParse(data['eventEndDate']);
      }
    }

    EventStatus status;
    switch (data['status']) {
      case 'draft': status = EventStatus.draft; break;
      case 'soldOut': status = EventStatus.soldOut; break;
      case 'ended': status = EventStatus.ended; break;
      case 'cancelled': status = EventStatus.cancelled; break;
      default: status = EventStatus.published;
    }

    DateTime? createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    return Ticket(
      id: id,
      eventName: data['eventName'] ?? data['title'] ?? '',
      eventDescription: data['eventDescription'] ?? data['description'] ?? '',
      eventImage: data['eventImage'] ?? data['imageUrl'] ?? '',
      venue: data['venue'] ?? '',
      eventDate: parsedDate,
      eventEndDate: endDate,
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      category: data['category'] ?? '',
      availableSeats: data['availableSeats'] ?? 0,
      totalSeats: data['totalSeats'] ?? data['availableSeats'] ?? 0,
      organizer: data['organizer'] ?? '',
      organizerId: data['organizerId'] ?? '',
      status: status,
      isFeatured: data['isFeatured'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      city: data['city'] ?? 'Colombo',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'eventName': eventName,
    'eventDescription': eventDescription,
    'eventImage': eventImage,
    'venue': venue,
    'eventDate': Timestamp.fromDate(eventDate),
    'eventEndDate': eventEndDate != null ? Timestamp.fromDate(eventEndDate!) : null,
    'price': price,
    'category': category,
    'availableSeats': availableSeats,
    'totalSeats': totalSeats,
    'organizer': organizer,
    'organizerId': organizerId,
    'status': status.name,
    'isFeatured': isFeatured,
    'tags': tags,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'createdAt': FieldValue.serverTimestamp(),
  };

  Ticket copyWith({
    String? eventName,
    String? eventDescription,
    String? eventImage,
    String? venue,
    DateTime? eventDate,
    DateTime? eventEndDate,
    double? price,
    String? category,
    int? availableSeats,
    int? totalSeats,
    String? organizer,
    String? organizerId,
    EventStatus? status,
    bool? isFeatured,
    List<String>? tags,
    List<TicketType>? ticketTypes,
    String? city,
  }) {
    return Ticket(
      id: id,
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventImage: eventImage ?? this.eventImage,
      venue: venue ?? this.venue,
      eventDate: eventDate ?? this.eventDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      price: price ?? this.price,
      category: category ?? this.category,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      organizer: organizer ?? this.organizer,
      organizerId: organizerId ?? this.organizerId,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      ticketTypes: ticketTypes ?? this.ticketTypes,
      city: city ?? this.city,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
    );
  }
}
