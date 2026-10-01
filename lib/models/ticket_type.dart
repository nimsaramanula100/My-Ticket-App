// lib/models/ticket_type.dart
// ─────────────────────────────────────────────────────────────────────────────
// TicketType Model | Ticket වර්ගයේ ආකෘතිය
// Represents one pricing tier / admission category for an event.
// සිදුවීමක් සඳහා එක් මිළ ස්ථරයක් / ඇතුළත් වීමේ කාණ්ඩයක් නිරූපණය කරයි.
// Examples: "VIP", "General Access", "Early Bird"
// ─────────────────────────────────────────────────────────────────────────────

class TicketType {
  // Firestore document ID | Firestore ලේඛන ID
  final String id;

  // The event this ticket type belongs to | මෙම ticket වර්ගය අයත් සිදුවීමේ ID
  final String eventId;

  // Display name of the tier | Tier හි ප්‍රදර්ශන නම (e.g. "VIP", "Regular", "Early Bird")
  final String name;        // e.g. "VIP", "Regular", "Early Bird"

  // Price per ticket in LKR | ලංකා රුපියල් (LKR) වලින් ticket ගණකයක් සඳහා මිළ
  final double price;

  // Total number of tickets created for this tier | මෙම tier සඳහා නිර්මිත ticket ගණන
  final int totalQuantity;

  // Remaining tickets available for purchase | ගැනීමට ඉතිරිව ඇති ticket ගණන
  final int availableQuantity;

  // Optional description of what this tier offers | මෙම tier ලබා දෙන දේ පිළිබඳ විස්තරය
  final String description;

  // List of perks/benefits that come with this tier
  // මෙම tier සමඟ ලැබෙන ප්‍රතිලාභ/වරප්‍රසාද ලැයිස්තුව
  final List<String> perks;

  // Whether this tier is currently active (visible to buyers)
  // මෙම tier දැනට සක්‍රීය ද (ගෝලකරුවන්ට දිස් වේ)
  final bool isActive;

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
  TicketType({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.totalQuantity,
    required this.availableQuantity,
    this.description = '',
    this.perks = const [],
    this.isActive = true,
  });

  // Returns true when no tickets are available | Ticket නොමැති විට true ලබා දෙයි
  bool get isSoldOut => availableQuantity <= 0;

  // Returns the fraction of tickets sold (0.0 to 1.0) for progress bars
  // Progress bar සඳහා විකිණූ ticket කොටස ලබා දෙයි (0.0 සිට 1.0 දක්වා)
  double get soldPercentage =>
      totalQuantity > 0 ? (totalQuantity - availableQuantity) / totalQuantity : 0.0;

  // ─── Factory from Firestore Map | Firestore Map වලින් factory ────────────────
  // Converts raw Firestore data into a TicketType object.
  // Firestore දත්ත TicketType object බවට පරිවර්තනය කරයි.
  factory TicketType.fromMap(Map<String, dynamic> data, String id) {
    return TicketType(
      id: id,
      eventId: data['eventId'] ?? '',
      name: data['name'] ?? 'Regular',
      // Safely parse price even if it comes as String or int
      // String හෝ int ලෙස ලැබුනත් ආරක්ෂිතව price parse කරයි
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      totalQuantity: data['totalQuantity'] ?? 0,
      availableQuantity: data['availableQuantity'] ?? 0,
      description: data['description'] ?? '',
      perks: List<String>.from(data['perks'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  // ─── Convert to Map for Firestore | Firestore සඳහා Map බවට ─────────────────
  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'name': name,
    'price': price,
    'totalQuantity': totalQuantity,
    'availableQuantity': availableQuantity,
    'description': description,
    'perks': perks,
    'isActive': isActive,
  };

  // ─── copyWith — Returns a modified copy | වෙනස් කළ copy ────────────────────
  // Useful for updating specific fields without mutating the original.
  // Original වෙනස් නොකර නිශ්චිත ක්ෂේත්‍ර යාවත්කාලීන කිරීමට ප්‍රයෝජනවත්.
  TicketType copyWith({
    String? name,
    double? price,
    int? totalQuantity,
    int? availableQuantity,
    String? description,
    List<String>? perks,
    bool? isActive,
  }) {
    return TicketType(
      id: id,
      eventId: eventId,
      name: name ?? this.name,
      price: price ?? this.price,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      description: description ?? this.description,
      perks: perks ?? this.perks,
      isActive: isActive ?? this.isActive,
    );
  }
}
