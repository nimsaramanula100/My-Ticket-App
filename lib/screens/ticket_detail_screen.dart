// lib/screens/ticket_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// TicketDetailScreen | ප්‍රවේශපත්‍ර විස්තර තිරය (Ticket Detail Screen)
// The main event detail screen. Displays event info, ticket type selection,
// available deals, payment methods, more info, booking policy, organizer details,
// and a sticky bottom checkout bar. Integrates Razorpay for payments.
// ප්‍රධාන සිදුවීම් විස්තර තිරය. Event info, ticket type selection, deals, payment
// methods, more info, booking policy, organizer details, සහ checkout bar අඩංගු.
// ගෙවීම් සඳහා Razorpay integrate කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/ticket.dart';
import '../models/booking.dart';
import '../models/ticket_type.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/color_palette.dart';
import 'demo_payment_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket? ticket;

  const TicketDetailScreen({super.key, this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  // ─── State Variables | State විචල්‍ය ───────────────────────────────────────
  bool _loading = false; // General loading flag | සාමාන්‍ය loading flag
  bool _loadingTicketTypes =
      true; // True while fetching ticket types | Ticket types ලෝඩ් වෙද්දී true
  late Razorpay _razorpay; // Razorpay SDK instance | Razorpay SDK instance
  String?
      _currentBookingId; // ID of booking created before payment | ගෙවීමට පෙර සෑදූ booking ID

  List<TicketType> _ticketTypes =
      []; // All ticket types for this event | මෙම සිදුවීමේ ticket types
  TicketType?
      _selectedTicketType; // Currently selected ticket type | දැනට තෝරාගත් ticket type

  // ─── initState: Set up Razorpay listeners and fetch ticket types ──────────
  // _initState: Razorpay listeners set up කර ticket types ලෝඩ් කරයි
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    // Register Razorpay event handlers | Razorpay event handlers ලියාපදිංචි කරයි
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchTicketTypes(); // Load ticket phases from Firestore | Firestore හි ticket phases ලෝඩ් කරයි
  }

  // ─── dispose: Clean up Razorpay to prevent memory leaks ─────────────────
  // dispose: Razorpay ශ්‍රවකයන් ඉවත් කර memory leaks වළකිනය
  @override
  void dispose() {
    _razorpay
        .clear(); // Remove all Razorpay event listeners | සියළු Razorpay listeners ඉවත් කරයි
    super.dispose();
  }

  // ─── _fetchTicketTypes: Load ticket types/phases from Firestore ──────────
  // _fetchTicketTypes: Firestore හි ticket phases (types) ලෝඩ් කරයි
  Future<void> _fetchTicketTypes() async {
    final t = widget.ticket;
    if (t == null) return; // Safety guard | ආරක්ෂිත guard
    try {
      // Fetch all TicketType subcollection documents for this event
      // මෙම සිදුවීම සඳහා TicketType subcollection documents ලබා ගනී
      final types = await FirestoreService().getTicketTypes(t.id);
      if (mounted) {
        setState(() {
          _ticketTypes = types;
          // Fallback if no ticket types are created (legacy event compatibility)
          // Ticket types නොමැතිනම් (legacy events) default ticket type සෑදෙයි
          if (_ticketTypes.isEmpty) {
            _ticketTypes = [
              TicketType(
                id: 'default',
                eventId: t.id,
                name: 'General Access',
                price: t.price,
                totalQuantity: t.totalSeats,
                availableQuantity: t.availableSeats,
                description: 'Standard Admission Ticket',
              )
            ];
          }
          // Auto-select the first non-sold-out ticket type as default
          // Sold-out නොවන පළමු ticket type ස්වයංක්‍රීයව select කරයි
          _selectedTicketType = _ticketTypes.firstWhere(
            (type) => !type.isSoldOut,
            orElse: () => _ticketTypes.first,
          );
          _loadingTicketTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingTicketTypes =
              false; // End loading even on error | දෝෂයකදීත් loading නිම කරයි
        });
      }
    }
  }

  // ─── _handlePaymentSuccess: Razorpay success callback ───────────────────
  // _handlePaymentSuccess: ගෙවීම සාර්ථකව ව්ද විට Razorpay callback ශ්‍රිතය
  // Updates booking status to 'paid' in Firestore, then shows success dialog.
  // Firestore හි booking status 'paid' ලෙස update කර success dialog දක්වයි.
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentBookingId == null) return;
    try {
      setState(() => _loading = true);
      // Mark the booking as paid in Firestore | Firestore හි booking 'paid' ලෙස සලකුණු කරයි
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

  // ─── _handlePaymentError: Razorpay failure callback ──────────────────────
  // _handlePaymentError: ගෙවීම අසාර්ථක වූ විට Razorpay callback ශ්‍රිතය
  // Updates booking status to 'failed' and shows error snackbar.
  // Booking status 'failed' ලෙස update කර error snackbar දක්වයි.
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
      // Error during failure handling — silently ignored
      // Failure handling අතරතුර දෝෂය — නිශ්ශබ්දව ignore කරයි
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── _handleExternalWallet: Razorpay external wallet callback ───────────
  // _handleExternalWallet: External wallet (e.g. PayTM) select කළ විට callback
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  // ─── _showSuccessDialog: Non-dismissible payment confirmation dialog ───────
  // _showSuccessDialog: Dismiss කළ නොහැකි ගෙවීම් තහවුරු dialog
  // Shows booking ID + payment ID. Popping it also pops the detail screen.
  // Booking ID + payment ID දක්වයි. Dialog pop කළ විට detail screen ද pop වේ.
  void _showSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B172E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Payment Successful', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your booking has been confirmed!',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(
              'Booking ID: $_currentBookingId',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white),
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

  // ─── _showBookingBottomSheet: Quantity picker + Pay Now bottom sheet ──────
  // _showBookingBottomSheet: Ticket ගණන picker + Pay Now bottom sheet
  // Guard-checks for login. Uses StatefulBuilder so only the sheet rebuilds
  // when quantity changes, not the whole screen.
  // Login guard-check කරයි. ගණන වෙනස් වූ විට screen නොව sheet පමණ rebuild.
  void _showBookingBottomSheet() {
    final ticket = widget.ticket;
    final selectedType = _selectedTicketType;
    if (ticket == null || selectedType == null) return;

    // Guard: require login before booking | Guard: booking කිරීමට ලොගිනය අවශ්‍ය
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please login first')));
      Navigator.of(context).pushNamed('/login');
      return;
    }

    // Local state inside the sheet | Sheet ඇතුළත local state
    int quantity = 1;
    final double price = selectedType.price;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B172E),
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
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ticket.title} - ${selectedType.name}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ticket.currency} ${price.toStringAsFixed(2)} / ticket',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
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
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: quantity < selectedType.availableQuantity
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
                  const Divider(color: AppColors.surfaceVariant),
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
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '${ticket.currency} ${totalPrice.toStringAsFixed(2)}',
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

  // ─── _startPayment: Create booking in Firestore → open DemoPaymentScreen ─
  // _startPayment: Firestore හි booking සාදා → DemoPaymentScreen විවෘත කරයි
  // Step 1: Build a Booking object with 'pending' status.
  // Step 2: Persist it to Firestore to reserve the seat.
  // Step 3: Navigate to DemoPaymentScreen with the booking ID.
  // Step 1: 'pending' status සහිත Booking object ගොඩනඟයි.
  // Step 2: ආසනය reserve කිරීමට Firestore ට persist කරයි.
  // Step 3: Booking ID සමඟ DemoPaymentScreen ලෙසට navigate කරයි.
  Future<void> _startPayment(int quantity, double totalPrice) async {
    final ticket = widget.ticket;
    final selectedType = _selectedTicketType;
    if (ticket == null || selectedType == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Auth guard | ප්‍රමාණීකරණ guard

    // Get app user profile for pre-filling booking fields
    // Booking fields පූරවීමට app user profile ලබා ගනී
    final appUser = context.read<AuthProvider>().appUser;

    setState(() => _loading = true);

    try {
      // Build the Booking object | Booking object ගොඩනඟයි
      final booking = Booking(
        id: '',
        userId: user.uid,
        ticketId: ticket.id,
        organizerId: ticket.organizerId,
        eventName: ticket.title,
        bookingDate: DateTime.now(),
        quantity: quantity,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        paymentMethod: 'razorpay',
        ticketTypeId: selectedType.id,
        ticketTypeName: selectedType.name,
        userEmail: appUser?.email ?? user.email ?? '',
        userName: appUser?.displayName ?? user.displayName ?? '',
        userPhone: appUser?.phone ?? '',
      );

      final bookingId = await FirestoreService().createBooking(booking);
      _currentBookingId = bookingId;

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DemoPaymentScreen(
            bookingId: bookingId,
            amount: totalPrice,
            currency: ticket.currency,
            description: '${ticket.title} - ${selectedType.name} x$quantity',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initiate payment: $e')),
      );
      setState(() => _loading = false);
    }
  }

  // ─── build: Renders the full ticket detail page ───────────────────────────
  // build: සම්පූර්ණ ticket detail page render කරයි
  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    // Guard: show error if no ticket was passed | Guard: ticket නොදුන්නේ නම් error
    if (t == null) {
      return const Scaffold(body: Center(child: Text('No ticket details.')));
    }

    // ── Format date and time for display | Display සඳහා දිනය සහ වේලාව format කරයි ──
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(t.eventDate);
    final formattedTime = DateFormat('hh:mm a').format(t.eventDate);
    // Build a timeSpan string; handles single-day vs multi-day events
    // Single-day vs multi-day events සඳහා timeSpan string ගොඩනඟයි
    String timeSpan = '$formattedDate at $formattedTime';
    if (t.eventEndDate != null) {
      final formattedEndDate =
          DateFormat('dd MMMM yyyy').format(t.eventEndDate!);
      final formattedEndTime = DateFormat('hh:mm a').format(t.eventEndDate!);
      // Same day → show time range only | එකම දිනක් → time range පමණ
      if (t.eventDate.day == t.eventEndDate!.day &&
          t.eventDate.month == t.eventEndDate!.month) {
        timeSpan = '$formattedDate, $formattedTime - $formattedEndTime';
      } else {
        // Multi-day event → show start and end dates | Multi-day → ආරම්භ සහ අවසන් දිනය
        timeSpan =
            '$formattedDate ($formattedTime) - $formattedEndDate ($formattedEndTime)';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF030F26),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Custom sliver header matching visual styles ────────────
              SliverAppBar(
                backgroundColor: const Color(0xFF0B172E),
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0B172E), Color(0xFF030F26)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              t.eventName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    timeSpan,
                                    style: const TextStyle(
                                        color: Color(0xE6FFFFFF), fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    t.venue,
                                    style: const TextStyle(
                                        color: Color(0xE6FFFFFF), fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (t.organizer.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 14, color: AppColors.accent),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.organizer.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // ── Double Column Structure in Mobile: Poster visual ───
                      Card(
                        color: const Color(0xFF0B172E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                              color: Color(0xFF1E2E4E), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: t.imageUrl.isNotEmpty
                                ? Image.network(t.imageUrl, fit: BoxFit.cover)
                                : Container(
                                    color: AppColors.primaryVariant,
                                    child: const Icon(Icons.event,
                                        size: 64, color: Colors.white38),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rates Summary list from image
                      if (!_loadingTicketTypes && _ticketTypes.isNotEmpty) ...[
                        Card(
                          color: const Color(0xFF0B172E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                                color: Color(0xFF1E2E4E), width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rates',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _ticketTypes.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(color: Color(0xFF1E2E4E)),
                                  itemBuilder: (ctx, idx) {
                                    final rate = _ticketTypes[idx];
                                    final isSelected =
                                        _selectedTicketType?.id == rate.id;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedTicketType = rate;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                rate.name,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? AppColors.accent
                                                      : Colors.white,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${widget.ticket?.currency ?? Ticket.defaultCurrency} ${rate.price.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? AppColors.accent
                                                    : Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Card 1: Available Deals | ── ලබා ගත හැකි ගනුදෙනු Card ──
                      // Only shown if the organizer has entered a deal title
                      // Organizer deal title ඇතුල් කළ නම් පමණ දක්වේ
                      if (t.dealTitle.isNotEmpty)
                        Card(
                          color: const Color(0xFF0B172E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                                color: Color(0xFF1E2E4E), width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Color(0xFF10B981), size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Available Deals',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.dealTitle,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                                if (t.dealDescription.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    t.dealDescription,
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      if (t.dealTitle.isNotEmpty) const SizedBox(height: 12),

                      // ── Card 2: Payment Methods | ── ගෙවීම් ක්‍රම Card ──────
                      // Wraps payment method chips generated by _buildPaymentMethodChip()
                      // _buildPaymentMethodChip() හරහා ගෙවීම් ක්‍රම chips render කරයි
                      Card(
                        color: const Color(0xFF0B172E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                              color: Color(0xFF1E2E4E), width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Color(0xFF10B981), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Available Payment Methods',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: t.paymentMethods
                                    .map((method) =>
                                        _buildPaymentMethodChip(method))
                                    .toList(),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'You can select the payment method in the checkout page',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Card 3: More Information | ── වැඩිදුර තොරතුරු Card ──
                      // Uses moreInformation field; falls back to eventDescription
                      // moreInformation ක්ෂේත්‍රය; eventDescription fallback ලෙස
                      _buildCollapsibleCard(
                        title: 'More information',
                        children: [
                          Text(
                            t.moreInformation.isNotEmpty
                                ? t.moreInformation
                                : t.eventDescription,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Card 4: Booking Policy | ── ගිවිසුම් ප්‍රතිපත්තිය Card ──
                      // Shows organizer's custom policy or the default 12-section policy
                      // Custom policy හෝ default 12-section policy දක්වයි
                      _buildCollapsibleCard(
                        title: 'Booking Policy',
                        children: t.customBookingPolicy.isNotEmpty
                            ? [
                                Text(
                                  t.customBookingPolicy,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                )
                              ]
                            : [
                                _buildPolicySection(
                                  emoji: '🎟️',
                                  number: '1',
                                  title: 'TICKET PURCHASE',
                                  items: [
                                    'All tickets are sold on a first-come, first-served basis',
                                    'Ticket purchase is only confirmed upon successful payment completion',
                                    'Tickets are non-transferable and non-resaleable without prior written consent from the organizer',
                                    'Each ticket is valid for one person only',
                                    'The organizer reserves the right to limit the number of tickets purchased per person',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '💳',
                                  number: '2',
                                  title: 'PAYMENT & PRICING',
                                  items: [
                                    'All ticket prices are inclusive of applicable taxes and service charges',
                                    'Payment must be completed at the time of purchase',
                                    'The organizer reserves the right to change ticket prices at any time without prior notice',
                                    'Promotional or discounted tickets are subject to specific terms and cannot be combined with other offers',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '🚫',
                                  number: '3',
                                  title: 'REFUND & CANCELLATION',
                                  items: [
                                    'All ticket sales are final — no refunds will be issued under any circumstances',
                                    'Tickets cannot be exchanged for a different category or date',
                                    'In the event of cancellation of the event by the organizer, ticket holders will be notified and a refund or credit will be offered at the organizer\'s discretion',
                                    'In the event of postponement, tickets will remain valid for the rescheduled date',
                                  ],
                                ),
                                _buildPolicySectionWithWarning(
                                  emoji: '🎫',
                                  number: '4',
                                  title: 'TICKET VALIDITY & ENTRY POLICY',
                                  warning:
                                      '⚠️  ONE eTICKET = ONE ENTRY. STRICTLY NO RE-ENTRY ONCE YOU EXIT THE VENUE.',
                                  items: [
                                    'Each e-ticket is valid for one person and one single entry only',
                                    'Your ticket will be scanned at the entrance — once scanned, the ticket is immediately void and cannot be reused',
                                    'Re-entry to the venue is strictly prohibited under any circumstances — once you exit, your ticket will not be accepted for re-entry regardless of the reason',
                                    'Duplicate, photocopied, or tampered tickets will be rejected and will result in immediate denial of entry',
                                    'The organizer reserves the right to refuse entry to any person presenting an invalid, duplicate, or tampered ticket — without a refund',
                                    'Gates open at the time shown — please plan your arrival accordingly',
                                  ],
                                ),
                                _buildPolicySectionWithWarningAndList(
                                  emoji: '🔍',
                                  number: '5',
                                  title: 'SECURITY CHECKS & PROHIBITED ITEMS',
                                  warning:
                                      '⚠️  ALL GUESTS WILL BE SUBJECT TO A MANDATORY SECURITY CHECK BEFORE ENTERING THE VENUE — NO EXCEPTIONS.',
                                  items: [
                                    'All guests must undergo a full security screening at the venue entrance prior to entry — including body checks and bag inspections',
                                    'Guests who refuse to comply with security screening will be denied entry without a refund',
                                    'The following items are strictly prohibited inside the venue:',
                                  ],
                                  prohibitedItems: [
                                    'Helmets',
                                    'Knives, blades & sharp objects',
                                    'Firearms & ammunition',
                                    'Explosives & fireworks',
                                    'Lighters & matches',
                                    'Backpacks & large bags',
                                    'Pepper spray & tasers',
                                    'Glass bottles & containers',
                                    'Alcohol & outside beverages',
                                    'Illegal substances & drugs',
                                    'Professional cameras & recording equipment',
                                    'Selfie sticks & tripods',
                                    'Laser pointers',
                                    'Any item deemed dangerous by security personnel',
                                  ],
                                  trailingItems: [
                                    'The organizer and security team reserve the right to confiscate any prohibited item found during screening',
                                    'Guests found in possession of prohibited items will be denied entry or removed from the venue — without a refund',
                                    'The organizer is not responsible for any confiscated items',
                                  ],
                                ),
                                _buildPolicySectionWithWarning(
                                  emoji: '🍽️',
                                  number: '6',
                                  title: 'FOOD & BEVERAGES',
                                  warning:
                                      '⚠️  OUTSIDE FOOD & BEVERAGES ARE STRICTLY NOT PERMITTED INSIDE THE VENUE.',
                                  items: [
                                    'Guests are not permitted to bring any food, beverages, or drinks from outside into the venue',
                                    'Outside food and beverages found during security checks will be confiscated at the entrance',
                                    'A wide selection of food and beverages is available for purchase inside the venue',
                                    'Guests are encouraged to enjoy the full F&B experience available within the event premises',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '📋',
                                  number: '7',
                                  title: 'AGE RESTRICTIONS',
                                  items: [
                                    'This event is strictly for persons aged 18 years and above',
                                    'Valid government-issued photo ID may be required at the entrance',
                                    'The organizer reserves the right to refuse entry to any person unable to verify their age',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '🔒',
                                  number: '8',
                                  title: 'GUEST CONDUCT & BEHAVIOR',
                                  items: [
                                    'All guests are expected to conduct themselves in a respectful and responsible manner at all times',
                                    'The organizer reserves the right to remove any guest from the venue for disruptive, offensive, violent, or inappropriate behavior — without a refund',
                                    'Guests under the influence of alcohol or illegal substances may be refused entry or removed from the venue',
                                    'Any form of harassment, discrimination, or offensive behavior will result in immediate removal from the venue',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '📸',
                                  number: '9',
                                  title: 'PHOTOGRAPHY & RECORDING',
                                  items: [
                                    'Professional cameras, video cameras, and recording equipment are strictly prohibited',
                                    'The organizer and artist reserve all rights to any event photography and video content',
                                    'By attending the event, ticket holders consent to being photographed or filmed for promotional purposes by the organizer',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '⚠️',
                                  number: '10',
                                  title: 'LIABILITY',
                                  items: [
                                    'The organizer shall not be held liable for any personal injury, loss, or damage suffered at the event',
                                    'The organizer reserves the right to make changes to the event program, lineup, or schedule without prior notice',
                                    'In the event of circumstances beyond the organizer\'s control — including but not limited to natural disasters, government restrictions, or force majeure — the organizer shall not be held liable',
                                    'Guests attend the event at their own risk',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '📱',
                                  number: '11',
                                  title: 'eTICKET DELIVERY',
                                  items: [
                                    'E-tickets will be delivered to the registered email address upon successful payment',
                                    'MyTickets.lk is not responsible for tickets sent to an incorrectly entered email address',
                                    'Please ensure your contact details are accurate at the time of purchase',
                                    'E-tickets must be presented at the entrance — either on a mobile device or as a printed copy',
                                  ],
                                ),
                                _buildPolicySection(
                                  emoji: '📞',
                                  number: '12',
                                  title: 'CONTACT & DISPUTES',
                                  items: [
                                    'For any ticket-related queries, please contact MyTickets.lk via WhatsApp +94727600700 or support@mytickets.lk',
                                    'Any disputes arising from ticket purchases shall be subject to the laws of Sri Lanka',
                                    'The organizer\'s decision on all matters relating to the event shall be final and binding',
                                  ],
                                ),
                              ],
                      ),
                      const SizedBox(height: 12),

                      // ── Card 5: Organizer Details | ── සංවිධායක විස්තර Card ──
                      // Shows organizer profile, venue, capacity, and support contact
                      // Organizer profile, venue, capacity, support contact දක්වයි
                      _buildCollapsibleCard(
                        title: 'Organizer Details',
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.organizerAccent
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.organizerAccent,
                                      width: 1.5),
                                ),
                                child: const Icon(Icons.business_center_rounded,
                                    color: AppColors.organizerAccent, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.organizer.isNotEmpty
                                          ? t.organizer
                                          : 'Event Organizer',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.city.isNotEmpty
                                          ? '${t.city}, Sri Lanka'
                                          : 'Sri Lanka',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (t.organizerAbout.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              t.organizerAbout,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFF1E2E4E), thickness: 1),
                          const SizedBox(height: 12),
                          _buildOrganizerInfoRow(
                              Icons.location_city_outlined, 'Venue', t.venue),
                          const SizedBox(height: 10),
                          _buildOrganizerInfoRow(Icons.category_outlined,
                              'Event Category', t.category),
                          const SizedBox(height: 10),
                          _buildOrganizerInfoRow(
                            Icons.event_seat_outlined,
                            'Total Capacity',
                            '${t.totalSeats} seats',
                          ),
                          const SizedBox(height: 10),
                          _buildOrganizerInfoRow(
                            Icons.confirmation_number_outlined,
                            'Available Tickets',
                            '${t.availableSeats} remaining',
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF030F26),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFF1E2E4E)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.support_agent_outlined,
                                    color: AppColors.accent, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Support & Enquiries',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (t.organizerPhone.isNotEmpty ||
                                                t.organizerEmail.isNotEmpty)
                                            ? '${t.organizerPhone.isNotEmpty ? "Phone/WhatsApp: ${t.organizerPhone}" : ""}${t.organizerPhone.isNotEmpty && t.organizerEmail.isNotEmpty ? "\n" : ""}${t.organizerEmail.isNotEmpty ? "Email: ${t.organizerEmail}" : ""}'
                                            : 'WhatsApp: +94 727 600 700\nsupport@mytickets.lk',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Card 6: Available Times / Ticket Phases ─────────────
                      // ── ලබා ගත හැකි වේලාවන් / Ticket Phases Card ────────────
                      // Lists all ticket types; tapping selects one for checkout
                      // Ticket types ලැයිස්තු කරයි; tap කළ විට checkout සඳහා select
                      _buildCollapsibleCard(
                        title: 'Available Times',
                        initiallyExpanded: true,
                        children: [
                          if (_loadingTicketTypes)
                            const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.accent))
                          else if (_ticketTypes.isEmpty)
                            const Text('No ticket details available.',
                                style: TextStyle(color: Colors.white54))
                          else
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _ticketTypes.length,
                              itemBuilder: (context, index) {
                                final phase = _ticketTypes[index];
                                final isSelected =
                                    _selectedTicketType?.id == phase.id;
                                final isSoldOut = phase.isSoldOut;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF162544)
                                        : const Color(0xFF030F26),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accent
                                          : const Color(0xFF1E2E4E),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: isSoldOut
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedTicketType = phase;
                                            });
                                          },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  phase.name,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    decoration: isSoldOut
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                              // On Sale / Sold Out status button
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isSoldOut
                                                      ? Colors.red.withValues(
                                                          alpha: 0.15)
                                                      : const Color(0xFF0F62FE)
                                                          .withValues(
                                                              alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isSoldOut
                                                        ? Colors.red
                                                        : const Color(
                                                            0xFF0F62FE),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  isSoldOut
                                                      ? 'Sold Out'
                                                      : 'On Sale Now',
                                                  style: TextStyle(
                                                    color: isSoldOut
                                                        ? Colors.red
                                                        : const Color(
                                                            0xFF0F62FE),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.access_time_outlined,
                                                  size: 14,
                                                  color: AppColors.textMuted),
                                              const SizedBox(width: 6),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 12),
                                              ),
                                              const Text(' • ',
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.textMuted)),
                                              Text(
                                                formattedTime,
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: AppColors.accent),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  t.venue,
                                                  style: const TextStyle(
                                                      color: Color(0xE6FFFFFF),
                                                      fontSize: 13),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(
                          height: 120), // Spacing for floating bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Floating Bottom Checkout Bar ────────────────────────────────
          // ── ස්ථාවර checkout bar — Stack හි bottom positioned ───────────────
          // Shows selected ticket type name, price, and Book Now button
          // Selected ticket type නාමය, මිල, සහ Book Now button දක්වයි
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B172E),
                border: const Border(
                    top: BorderSide(color: Color(0xFF1E2E4E), width: 1.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedTicketType != null
                                ? _selectedTicketType!.name.toUpperCase()
                                : 'SELECT TICKET',
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedTicketType != null
                                ? '${widget.ticket?.currency ?? Ticket.defaultCurrency} ${_selectedTicketType!.price.toStringAsFixed(2)}'
                                : '${widget.ticket?.currency ?? Ticket.defaultCurrency} 0.00',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (_loading ||
                              _selectedTicketType == null ||
                              _selectedTicketType!.isSoldOut)
                          ? null
                          : _showBookingBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F62FE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _selectedTicketType != null &&
                                      _selectedTicketType!.isSoldOut
                                  ? 'Sold Out'
                                  : '${_selectedTicketType?.name ?? "Book"} • Book Now',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
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

  // ─── _buildBrandCard: Styled card widget for payment brand logos ──────────
  // _buildBrandCard: ගෙවීම් brand logos සඳහා styled card widget
  Widget _buildBrandCard({required Widget child, Color color = Colors.white}) {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF1E2E4E), width: 1),
      ),
      child: child,
    );
  }

  // ─── _buildCollapsibleCard: Expandable card with a title and child list ───
  // _buildCollapsibleCard: Title සහ children සහිත expand කළ හැකි card
  // Wraps Flutter's ExpansionTile in a styled Card
  // Flutter ExpansionTile styled Card ලෙස wrap කරයි
  Widget _buildCollapsibleCard({
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      color: const Color(0xFF0B172E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E2E4E), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white70,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          children: children,
        ),
      ),
    );
  }

  // ─── Policy Section Helpers | ── ප්‍රතිපත්ති කොටස් helpers ─────────────────
  // Three variants: plain list, list+warning banner, list+warning+prohibited grid
  // Variants 3: සාමාන්‍ය ලැයිස්තුව, warning banner, prohibited items grid

  // _buildPolicySection: Numbered policy section with bullet list
  // _buildPolicySection: Bullet list සහිත numbered policy section
  Widget _buildPolicySection({
    required String emoji,
    required String number,
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$number. $title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFF1E2E4E), thickness: 0.5),
        ],
      ),
    );
  }

  // _buildPolicySectionWithWarning: Policy section with an orange warning box
  // _buildPolicySectionWithWarning: Orange warning box සහිත policy section
  Widget _buildPolicySectionWithWarning({
    required String emoji,
    required String number,
    required String title,
    required String warning,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$number. $title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              warning,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFF1E2E4E), thickness: 0.5),
        ],
      ),
    );
  }

  // _buildPolicySectionWithWarningAndList: Policy section with warning + red prohibited grid
  // _buildPolicySectionWithWarningAndList: Warning + red prohibited grid සහිත policy section
  Widget _buildPolicySectionWithWarningAndList({
    required String emoji,
    required String number,
    required String title,
    required String warning,
    required List<String> items,
    required List<String> prohibitedItems,
    required List<String> trailingItems,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$number. $title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              warning,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
          // Prohibited items grid
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2), width: 1),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: prohibitedItems
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.25),
                              width: 1),
                        ),
                        child: Text(
                          '🚫  $item',
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ))
                  .toList(),
            ),
          ),
          ...trailingItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFF1E2E4E), thickness: 0.5),
        ],
      ),
    );
  }

  // ─── _buildPaymentMethodChip: Renders a branded badge for each payment method ─
  // _buildPaymentMethodChip: සෑම ගෙවීම් ක්‍රමයකටම branded badge render කරයි
  // Mastercard → overlapping circles, Visa → dark blue, Koko → purple, default → text
  // Mastercard → circles, Visa → dark blue, Koko → purple, default → text badge
  Widget _buildPaymentMethodChip(String method) {
    switch (method.toLowerCase()) {
      case 'mastercard':
        return _buildBrandCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
              Transform.translate(
                offset: const Offset(-4, 0),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        );
      case 'visa':
        return _buildBrandCard(
          color: const Color(0xFF0A2B88),
          child: const Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      case 'koko':
        return _buildBrandCard(
          color: const Color(0xFF5F00F5),
          child: const Center(
            child: Text(
              'koko',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        );
      default:
        // Generic text badge
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2E4E),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF304060), width: 1),
          ),
          child: Text(
            method,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  // ─── _buildOrganizerInfoRow: Icon + label/value row in organizer details card ─
  // _buildOrganizerInfoRow: Organizer details card හි icon + label/value row
  Widget _buildOrganizerInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.organizerAccent, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
