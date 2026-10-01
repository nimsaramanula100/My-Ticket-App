// lib/screens/payment_success_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// PaymentSuccessScreen | ගෙවීම සාර්ථකත්ව Screen
// Shown after a successful demo payment.
// Demo ගෙවීමක් සාර්ථකව ව්ද පසු දක්වයි.
// Displays the booking ID and payment ID for the user's reference.
// User ගේ reference සඳහා booking ID සහ payment ID දක්වයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';

// ─── PaymentSuccessScreen Widget ──────────────────────────────────────────────
class PaymentSuccessScreen extends StatelessWidget {
  // The Firestore booking document ID | Firestore booking ලේඛන ID
  final String bookingId;

  // The generated demo payment ID | Generate කළ demo payment ID
  final String paymentId;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Success Icon (green checkmark in a circle) ──────────────
                // ── සාර්ථකත්ව Icon (කොළ circle හි checkmark) ────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Semi-transparent green background for the icon
                    // Icon සඳහා semi-transparent කොළ background
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Main Success Heading | ප්‍රධාන සාර්ථකත්ව Heading ─────────
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirmation subtitle | Confirmation subtitle ─────────────
                const Text(
                  'Your booking has been confirmed.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Booking Details Card | Booking Details Card ───────────────
                // Shows the booking ID and payment ID for the user's records.
                // User ගේ records සඳහා booking ID සහ payment ID දක්වයි.
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    children: [
                      // Booking ID row | Booking ID row
                      _buildInfoRow('Booking ID', bookingId),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.surfaceVariant),
                      const SizedBox(height: 12),
                      // Payment ID row | Payment ID row
                      _buildInfoRow('Payment ID', paymentId),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // ── Back to Home Button | Home Button ────────────────────────
                // Clears the entire navigation stack and goes back to Home.
                // සම්පූර්ණ navigation stack ඉවත් කර Home ලෙසට යයි.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // pushNamedAndRemoveUntil removes all previous routes
                      // pushNamedAndRemoveUntil — කලින් routes සියල්ල ඉවත් කරයි
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── _buildInfoRow: Reusable label-value row widget ───────────────────────────
  // Displays a label on the left and a value on the right.
  // වමේ label සහ දකුණේ value දක්වන reusable widget.
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label text (muted color) | Label text (muted color)
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        // Value text (white, bold) | Value text (සුදු, bold)
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
