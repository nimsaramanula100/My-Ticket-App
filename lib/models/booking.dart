class Booking {
  final String id;
  final String userId;
  final String ticketId;
  final String eventName;
  final DateTime bookingDate;
  final int quantity;
  final double totalPrice;
  final String status;
  final String paymentMethod;

  Booking({
    required this.id,
    required this.userId,
    required this.ticketId,
    required this.eventName,
    required this.bookingDate,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
  });

  factory Booking.fromMap(Map<String, dynamic> data, String docId) {
    return Booking(
      id: docId,
      userId: data['userId'] ?? '',
      ticketId: data['ticketId'] ?? '',
      eventName: data['eventName'] ?? '',
      bookingDate: data['bookingDate'] != null
          ? DateTime.parse(data['bookingDate'])
          : DateTime.now(),
      quantity: data['quantity'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'card',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'ticketId': ticketId,
      'eventName': eventName,
      'bookingDate': bookingDate.toIso8601String(),
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
      'paymentMethod': paymentMethod,
    };
  }
}
