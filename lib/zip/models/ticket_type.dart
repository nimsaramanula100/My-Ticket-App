// lib/models/ticket_type.dart
class TicketType {
  final String id;
  final String eventId;
  final String name;        // e.g. "VIP", "Regular", "Early Bird"
  final double price;
  final int totalQuantity;
  final int availableQuantity;
  final String description;
  final List<String> perks;
  final bool isActive;

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

  bool get isSoldOut => availableQuantity <= 0;
  double get soldPercentage =>
      totalQuantity > 0 ? (totalQuantity - availableQuantity) / totalQuantity : 0.0;

  factory TicketType.fromMap(Map<String, dynamic> data, String id) {
    return TicketType(
      id: id,
      eventId: data['eventId'] ?? '',
      name: data['name'] ?? 'Regular',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      totalQuantity: data['totalQuantity'] ?? 0,
      availableQuantity: data['availableQuantity'] ?? 0,
      description: data['description'] ?? '',
      perks: List<String>.from(data['perks'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

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
