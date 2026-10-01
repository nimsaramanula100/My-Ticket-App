import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/ticket.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../theme/color_palette.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket? ticket;

  const TicketDetailScreen({super.key, this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _loading = false;
  late Razorpay _razorpay;
  String? _currentBookingId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentBookingId == null) return;
    try {
      setState(() => _loading = true);
      await FirestoreService().updateBookingStatus(_currentBookingId!, 'paid');
      _showSuccessDialog(response.paymentId ?? 'unknown');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating payment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    if (_currentBookingId == null) return;
    try {
      setState(() => _loading = true);
      await FirestoreService()
          .updateBookingStatus(_currentBookingId!, 'failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Failed: ${response.message ?? "User cancelled payment"}',
            ),
          ),
        );
      }
    } catch (e) {
      // Ignored
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  void _showSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your booking has been confirmed!'),
            const SizedBox(height: 12),
            Text(
              'Booking ID: $_currentBookingId',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Payment ID: $paymentId',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // pop dialog
              Navigator.of(context).pop(); // pop detail screen
            },
            child: const Text('Back to Events'),
          ),
        ],
      ),
    );
  }

  void _showBookingBottomSheet() {
    final ticket = widget.ticket;
    if (ticket == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please login first')));
      Navigator.of(context).pushNamed('/login');
      return;
    }

    int quantity = 1;
    final double price = ticket.price;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double totalPrice = price * quantity;
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Tickets',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${price.toStringAsFixed(2)} / ticket',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () => setModalState(() => quantity--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.accent,
                            iconSize: 28,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: quantity < ticket.availableSeats
                                ? () => setModalState(() => quantity++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.accent,
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Rs. ${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startPayment(quantity, totalPrice);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _startPayment(int quantity, double totalPrice) async {
    final ticket = widget.ticket;
    if (ticket == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final booking = Booking(
        id: '',
        userId: user.uid,
        ticketId: ticket.id,
        eventName: ticket.title,
        bookingDate: DateTime.now(),
        quantity: quantity,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        paymentMethod: 'razorpay',
      );

      final bookingId = await FirestoreService().createBooking(booking);
      _currentBookingId = bookingId;

      final options = {
        'key': 'rzp_test_5gT6qH8J8v9K2A',
        'amount': (totalPrice * 100).toInt(),
        'name': 'MyTickets App',
        'description': '${ticket.title} x$quantity',
        'prefill': {
          'email': user.email ?? 'test@example.com',
          'contact': '',
        },
        'notes': {
          'bookingId': bookingId,
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initiate payment: $e')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    if (t == null) {
      return const Scaffold(body: Center(child: Text('No ticket details.')));
    }

    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(t.eventDate);
    final formattedTime = DateFormat('hh:mm a').format(t.eventDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (t.imageUrl.isNotEmpty)
                        Image.network(t.imageUrl, fit: BoxFit.cover)
                      else
                        Container(
                          color: AppColors.primaryVariant,
                          child: const Icon(Icons.event,
                              size: 80, color: Colors.white70),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      if (t.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        t.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Venue row
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.venue,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date and Time row
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$formattedDate at $formattedTime',
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Organizer details
                      if (t.organizer.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.business_outlined,
                                color: AppColors.accent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Organized by: ${t.organizer}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Remaining Seats badge
                      Row(
                        children: [
                          Icon(
                            Icons.event_seat_outlined,
                            color: t.availableSeats <= 50
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${t.availableSeats} tickets available',
                            style: TextStyle(
                              fontSize: 15,
                              color: t.availableSeats <= 50
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Divider(),
                      const SizedBox(height: 20),

                      const Text(
                        'About Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        t.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(
                          height: 100), // Spacing for floating bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Navigation/Checkout Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Price from',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                        Text(
                          'Rs. ${t.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _loading ? null : _showBookingBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Book Tickets',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
