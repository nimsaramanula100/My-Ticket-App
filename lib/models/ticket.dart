// lib/models/ticket.dart
// ─────────────────────────────────────────────────────────────────────────────
// Ticket (Event) Model | ප්‍රවේශපත්‍ර (සිදුවීම්) ආකෘතිය
// Represents a single event that tickets are being sold for.
// ප්‍රවේශපත්‍ර අලෙවි කරනු ලබන එක් සිදුවීමක් නිරූපණය කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ticket_type.dart';

// Enum defining the current status of an event
// සිදුවීමක වත්මන් තත්වය නිර්වචනය කරන Enum එක
enum EventStatus { draft, published, soldOut, ended, cancelled }

// ─── Ticket Class | Ticket (ප්‍රවේශපත්‍ර) පන්තිය ───────────────────────────────────
// Holds all information about an event and its ticket details.
// සිදුවීමක් සහ එහි ප්‍රවේශපත්‍ර විස්තර පිළිබඳ සියලු තොරතුරු ඇතුළත් කරයි.
class Ticket {
  // Unique document ID in Firestore | Firestore හි ඇති අද්විතීය ලේඛන ID එක
  final String id;

  // Name/Title of the event | සිදුවීමේ නම / මාතෘකාව
  final String eventName;

  // Detailed description of the event | සිදුවීම පිළිබඳ සවිස්තරාත්මක විස්තරය
  final String eventDescription;

  // URL or path of the event banner image | සිදුවීමේ බැනර් රූපයේ URL හෝ මාර්ගය
  final String eventImage;

  // Venue location name where event is held | සිදුවීම පවත්වනු ලබන ස්ථානයේ නම
  final String venue;

  // Date and starting time of the event | සිදුවීම පැවැත්වෙන දිනය සහ ආරම්භක වේලාව
  final DateTime eventDate;

  // Optional ending date and time | විකල්ප අවසාන දිනය සහ වේලාව
  final DateTime? eventEndDate;

  // Base or starting price of a ticket | ප්‍රවේශපත්‍රයක මූලික මිල
  final double price;

  // Currency label for the ticket prices (e.g. Rs., USD)
  // ticket මිල සඳහා මුදල් ලේබලය (උදා. Rs., USD)
  final String currency;

  // Primary category of the event | සිදුවීමේ ප්‍රධාන කාණ්ඩය (e.g. Concert, Sports)
  final String category;

  // List of all categories this event matches | මෙම සිදුවීම ගැලපෙන සියලුම කාණ්ඩ ලැයිස්තුව
  final List<String> categories;

  // Number of remaining/available tickets | ඉතිරිව ඇති / ලබාගත හැකි ප්‍රවේශපත්‍ර ගණන
  final int availableSeats;

  // Total capacity or initial tickets count | මුළු ධාරිතාව හෝ ආරම්භක ප්‍රවේශපත්‍ර ගණන
  final int totalSeats;

  // Name of the organizer | සංවිධායකගේ නම
  final String organizer;

  // Linked organizer profile document ID | සංවිධායක පැතිකඩ ලේඛනයේ සම්බන්ධිත ID එක
  final String organizerId;

  // Status of the event (draft, published, etc.) | සිදුවීමේ තත්වය
  final EventStatus status;

  // Flag to highlight this event on the home screen | මෙම සිදුවීම ප්‍රධාන තිරයේ උද්දීපනය කිරීමට ඇති සලකුණ
  final bool isFeatured;

  // Search tags/keywords | සෙවීම් සඳහා ටැග්/මූල පද
  final List<String> tags;

  // List of different ticket pricing tiers (VIP, Regular, etc.)
  // විවිධ ප්‍රවේශපත්‍ර මිල ස්ථර ලැයිස්තුව (VIP, සාමාන්‍ය, ආදිය)
  final List<TicketType> ticketTypes;

  // City where the event is located | සිදුවීම පිහිටි නගරය
  final String city;

  // Geographic coordinates: Latitude | භූගෝලීය ඛණ්ඩාංක: අක්ෂාංශය
  final double? latitude;

  // Geographic coordinates: Longitude | භූගෝලීය ඛණ්ඩාංක: දේශාංශය
  final double? longitude;

  // Timestamp when event was registered | සිදුවීම ලියාපදිංචි කළ වේලාව
  final DateTime? createdAt;

  // Custom discount/deal title text | සංවිධායක විසින් සකසන ලද විශේෂ දීමනා මාතෘකාව
  final String dealTitle;

  // Custom discount/deal description | විශේෂ දීමනා පිළිබඳ විස්තරය
  final String dealDescription;

  // Payment gateways accepted for booking | වෙන්කරවා ගැනීම සඳහා පිළිගන්නා ගෙවීම් ක්‍රම
  final List<String> paymentMethods;

  // Short descriptive text about the organizer | සංවිධායක පිළිබඳ කෙටි හැඳින්වීමක්
  final String organizerAbout;

  // Support/Contact telephone number | සහාය/සම්බන්ධතා දුරකථන අංකය
  final String organizerPhone;

  // Support/Contact email address | සහාය/සම්බන්ධතා ඊමේල් ලිපිනය
  final String organizerEmail;

  // Custom terms or cancellation policy | විශේෂ වෙන්කිරීම් හෝ අවලංගු කිරීමේ ප්‍රතිපත්තිය
  final String customBookingPolicy;

  // Rich description with further details | වැඩිදුර තොරතුරු ඇතුළත් සවිස්තරාත්මක විස්තරය
  final String moreInformation;

  static const String defaultCurrency = 'Rs.';

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
  Ticket({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    required this.eventImage,
    required this.venue,
    required this.eventDate,
    this.eventEndDate,
    required this.price,
    this.currency = defaultCurrency,
    required this.category,
    this.categories = const [],
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
    this.dealTitle = '',
    this.dealDescription = '',
    this.paymentMethods = const ['Visa', 'Mastercard', 'Koko'],
    this.organizerAbout = '',
    this.organizerPhone = '',
    this.organizerEmail = '',
    this.customBookingPolicy = '',
    this.moreInformation = '',
  }) : totalSeats = totalSeats ?? availableSeats;

  // ─── Getters (Backwards compatibility) | පසුගාමී අනුකූලතාව සඳහා Getters ───
  String get title => eventName;
  String get description => eventDescription;
  String get imageUrl => eventImage;

  // Check if event is active & public | සිදුවීම සක්‍රීයව සහ ප්‍රසිද්ධියේ පවතීද
  bool get isPublished => status == EventStatus.published;

  // Check if tickets are completely sold out | ප්‍රවේශපත්‍ර සම්පූර්ණයෙන්ම විකිණී අවසන් දැයි පරීක්ෂා කරයි
  bool get isSoldOut => availableSeats <= 0 || status == EventStatus.soldOut;

  // Check if the event date has already passed | සිදුවීම පැවැත්වෙන දිනය පසු වී ඇත්දැයි පරීක්ෂා කරයි
  bool get isEnded =>
      status == EventStatus.ended || eventDate.isBefore(DateTime.now());

  // Calculates percentage of tickets sold (0.0 to 1.0)
  // විකිණී ඇති ප්‍රවේශපත්‍ර ප්‍රතිශතය ගණනය කරයි (0.0 සිට 1.0 දක්වා)
  double get soldPercentage =>
      totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;

  // Formats the enum status value to readable string
  // Enum තත්ව අගය කියවිය හැකි පෙළක් බවට ආකෘතිකරණය කරයි
  String get statusText {
    switch (status) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Published';
      case EventStatus.soldOut:
        return 'Sold Out';
      case EventStatus.ended:
        return 'Ended';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }

  // ─── Factory constructor from Firestore Map | Firestore Map එකකින් Factory Constructor එක ───
  // Parses database key-value structure into a structured Ticket object.
  // දත්ත සමුදායේ යතුරු-අගය ව්‍යුහය ව්‍යුහගත Ticket වස්තුවක් බවට Parse කරයි.
  factory Ticket.fromMap(Map<String, dynamic> data, String id) {
    // Parse starting date safely | ආරම්භක දිනය ආරක්ෂිතව Parse කිරීම
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

    // Parse ending date safely | අවසාන දිනය ආරක්ෂිතව Parse කිරීම
    DateTime? endDate;
    if (data['eventEndDate'] != null) {
      if (data['eventEndDate'] is Timestamp) {
        endDate = (data['eventEndDate'] as Timestamp).toDate();
      } else if (data['eventEndDate'] is String) {
        endDate = DateTime.tryParse(data['eventEndDate']);
      }
    }

    // Parse status string into Enum | තත්ව String අගය Enum එකක් බවට Parse කිරීම
    EventStatus status;
    switch (data['status']) {
      case 'draft':
        status = EventStatus.draft;
        break;
      case 'soldOut':
        status = EventStatus.soldOut;
        break;
      case 'ended':
        status = EventStatus.ended;
        break;
      case 'cancelled':
        status = EventStatus.cancelled;
        break;
      default:
        status = EventStatus.published;
    }

    // Parse registration timestamp | ලියාපදිංචි කළ වේලාව Parse කිරීම
    DateTime? createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    // Return the built Ticket instance | ගොඩනඟන ලද Ticket වස්තුව ආපසු ලබා දීම
    return Ticket(
      id: id,
      eventName: data['eventName'] ?? data['title'] ?? '',
      eventDescription: data['eventDescription'] ?? data['description'] ?? '',
      eventImage: data['eventImage'] ?? data['imageUrl'] ?? '',
      venue: data['venue'] ?? '',
      eventDate: parsedDate,
      eventEndDate: endDate,
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      currency: data['currency'] ?? defaultCurrency,
      category: data['category'] ?? '',
      availableSeats: data['availableSeats'] ?? 0,
      totalSeats: data['totalSeats'] ?? data['availableSeats'] ?? 0,
      categories: List<String>.from(data['categories'] ??
          (data['category'] != null ? [data['category']] : ['Other'])),
      organizer: data['organizer'] ?? '',
      organizerId: data['organizerId'] ?? '',
      status: status,
      isFeatured: data['isFeatured'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      city: data['city'] ?? 'Colombo',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: createdAt,
      dealTitle: data['dealTitle'] ?? '',
      dealDescription: data['dealDescription'] ?? '',
      paymentMethods: List<String>.from(
          data['paymentMethods'] ?? ['Visa', 'Mastercard', 'Koko']),
      organizerAbout: data['organizerAbout'] ?? '',
      organizerPhone: data['organizerPhone'] ?? '',
      organizerEmail: data['organizerEmail'] ?? '',
      customBookingPolicy: data['customBookingPolicy'] ?? '',
      moreInformation: data['moreInformation'] ?? '',
    );
  }

  // ─── Convert Ticket to Map for Firestore | Firestore සඳහා Map එකකට පරිවර්තනය කිරීම ───
  // Serializes the Ticket properties to match Firestore document schema.
  // Firestore ලේඛන යෝජනා ක්‍රමයට ගැළපෙන පරිදි Ticket ගුණාංග Map එකක් බවට සකසයි.
  Map<String, dynamic> toMap() => {
        'eventName': eventName,
        'eventDescription': eventDescription,
        'eventImage': eventImage,
        'venue': venue,
        'eventDate': Timestamp.fromDate(eventDate),
        'eventEndDate':
            eventEndDate != null ? Timestamp.fromDate(eventEndDate!) : null,
        'price': price,
        'currency': currency,
        'category': category,
        'categories': categories,
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
        'dealTitle': dealTitle,
        'dealDescription': dealDescription,
        'paymentMethods': paymentMethods,
        'organizerAbout': organizerAbout,
        'organizerPhone': organizerPhone,
        'organizerEmail': organizerEmail,
        'customBookingPolicy': customBookingPolicy,
        'moreInformation': moreInformation,
      };

  // ─── copyWith - Create a modified copy | වෙනස් කළ පිටපතක් සාදා ගැනීම ────────────────────
  // Returns a new Ticket instance with selectively updated fields.
  // තෝරාගත් ක්ෂේත්‍ර පමණක් යාවත්කාලීන කරන ලද නව Ticket වස්තුවක් ලබා දෙයි.
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
    String? currency,
    List<String>? categories,
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
      currency: currency ?? this.currency,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      categories: categories ?? this.categories,
    );
  }
}
