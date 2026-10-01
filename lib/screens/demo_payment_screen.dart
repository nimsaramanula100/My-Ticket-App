// lib/screens/demo_payment_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// DemoPaymentScreen | Demo ගෙවීම් Screen
// Simulates a payment gateway for testing purposes.
// Testing කිරීම සඳහා payment gateway simulate කරයි.
//
// DEMO CARD DETAILS (correct details for payment success):
// DEMO CARD විස්තර (ගෙවීම සාර්ථකත්වය සඳහා නිවැරදි විස්තර):
//   Card Number : 4111 1111 1111 1111
//   Expiry Date : 12/25
//   CVV         : 123
//
// Any other values will result in a "Payment Unsuccessful" error.
// වෙනත් ඕනෑම values "ගෙවීම අසාර්ථකයි" error ලබා දෙනු ඇත.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import '../services/firestore_service.dart';
import 'payment_success_screen.dart';

// ─── DemoPaymentScreen Widget | Demo ගෙවීම් Widget ───────────────────────────
class DemoPaymentScreen extends StatefulWidget {
  // The booking ID to update after payment | ගෙවීමෙන් පසු update කළ booking ID
  final String bookingId;

  // Total amount to be paid | ගෙවිය යුතු මුළු මුදල
  final double amount;

  // A description of what is being paid for | ගෙවීම කරන්නේ කුමක් සඳහාද
  final String description;

  // Currency label used for display (Rs., USD, etc.)
  final String currency;

  const DemoPaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.description,
  });

  @override
  State<DemoPaymentScreen> createState() => _DemoPaymentScreenState();
}

class _DemoPaymentScreenState extends State<DemoPaymentScreen> {
  // Whether the payment is currently processing | ගෙවීම දැනට processing ද
  bool _isLoading = false;

  // Controllers for each card input field | හැෑදිරි card input field සඳහා controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // ─── dispose: Free memory when the screen is closed ───────────────────────────
  // TextEditingControllers must be disposed to avoid memory leaks.
  // Memory leaks වළකීමට TextEditingControllers dispose කළ යුතු වේ.
  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // ─── _processPayment: Validate card and process payment ───────────────────────
  // Step 1: Validate the entered card details against demo card values.
  // Step 2: If valid, simulate a 2-second delay (network call), update Firestore.
  // Step 3: Navigate to PaymentSuccessScreen on success.
  //
  // Step 1: ඇතුල් කළ card details demo card values සමඟ validate කරයි.
  // Step 2: Valid නම්, 2-second delay simulate කර (network call), Firestore update කරයි.
  // Step 3: සාර්ථකව ව්ද පසු PaymentSuccessScreen ලෙසට navigate කරයි.
  Future<void> _processPayment() async {
    // ── Validation: Check if the entered card matches demo card ──────────────────
    // ── Validation: ඇතුල් කළ card demo card සමඟ ගැළපේදැයි check කරයි ─────────
    if (_cardNumberController.text.replaceAll(' ', '') != '4111111111111111' ||
        _expiryDateController.text != '12/25' ||
        _cvvController.text != '123') {
      // Show a red error snackbar for wrong card details
      // වැරදි card details සඳහා රතු error snackbar දක්වයි
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment unsuccessful: Invalid demo card details.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop here — don't proceed to payment | මෙහිදී නවත්වයි — ගෙවීමට ඉදිරියට නොයයි
    }

    // Card is valid — show loading spinner
    // Card valid — loading spinner දක්වයි
    setState(() => _isLoading = true);

    try {
      // Simulate a real network payment API call with a 2-second delay
      // Real network payment API call simulate කිරීමට 2-second delay
      await Future.delayed(const Duration(seconds: 2));

      // Update the booking status to 'paid' in Firestore
      // Firestore හි booking status 'paid' ලෙස update කරයි
      await FirestoreService().updateBookingStatus(widget.bookingId, 'paid');

      // Make sure the widget is still mounted before navigating
      // Navigate කිරීමට පෙර widget mount ව ඇත්දැයි check කරයි
      if (!mounted) return;

      // Generate a unique demo payment ID using the current timestamp
      // Current timestamp භාවිතා කර unique demo payment ID generate කරයි
      final paymentId = 'DEMO_PAY_${DateTime.now().millisecondsSinceEpoch}';

      // Navigate to the success screen (replace this screen in the stack)
      // Success screen ලෙසට navigate කරයි (stack හි මෙම screen replace කරයි)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            bookingId: widget.bookingId,
            paymentId: paymentId,
          ),
        ),
      );
    } catch (e) {
      // Show an error snackbar if Firestore update fails
      // Firestore update fail නම් error snackbar දක්වයි
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      // Always hide the loading spinner whether success or failure
      // සාර්ථකත්වය හෝ අසාර්ථකත්වය, loading spinner සැමවිටම සඟවයි
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── build: Render the payment screen UI ──────────────────────────────────────
  // ─── build: ගෙවීම් screen UI render කරයි ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Secure Checkout'),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order Summary Card | ඇණවුම් සාරාංශ Card ────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description of what the user is buying | User ගන්නා දෙය පිළිබඳ විස්තරය
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceVariant),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.currency} ${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Payment Method Header | ගෙවීම් ක්‍රම Header ───────────────────
            const Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // ── Card Input Form | Card ඇතුල් කිරීමේ Form ─────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                // Highlighted border indicates this method is selected
                // Highlighted border — මෙම method selected ය
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5), width: 2),
              ),
              child: Column(
                children: [
                  // Card icon and label | Card icon සහ label
                  Row(
                    children: [
                      Icon(Icons.credit_card,
                          color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(width: 12),
                      const Text(
                        'Demo Credit Card',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.check_circle, color: AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Hint to remind the user of demo card values
                  // Demo card values user ට remind කිරීමට hint
                  const Text(
                    'Use Demo Card:\n4111 1111 1111 1111 | 12/25 | 123',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Card Number Field | Card අංක Field ────────────────────
                  TextFormField(
                    controller: _cardNumberController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      hintText: '4111 1111 1111 1111',
                      hintStyle: const TextStyle(color: Colors.white30),
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Expiry Date & CVV Row | Expiry Date සහ CVV Row ────────
                  Row(
                    children: [
                      // Expiry Date field | Expiry Date field
                      Expanded(
                        child: TextFormField(
                          controller: _expiryDateController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                            hintStyle: const TextStyle(color: Colors.white30),
                            labelStyle:
                                const TextStyle(color: AppColors.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // CVV field (hidden for security) | CVV field (ආරක්ෂාව සඳහා hidden)
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          obscureText: true, // Hide CVV input | CVV input සඟවයි
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            hintStyle: const TextStyle(color: Colors.white30),
                            labelStyle:
                                const TextStyle(color: AppColors.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Pay Button | ගෙවීම් Button ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Disable button while loading to prevent duplicate payments
                // Duplicate ගෙවීම් වළකීමට loading වන විට button disable කරයි
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Show a spinner while processing, otherwise show the pay amount
                // Processing වන විට spinner, නැතිනම් ගෙවිය යුතු මුදල දක්වයි
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Pay ${widget.currency} ${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
