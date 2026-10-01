// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../theme/color_palette.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user bookings after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isSignedIn && auth.firebaseUser != null) {
        context.read<BookingProvider>().loadUserBookings(
            auth.firebaseUser!.uid);
      }
    });
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<BookingProvider>().clear();
      await context.read<AuthProvider>().signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Not logged in — show login prompt
    if (!auth.isSignedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined,
                  size: 80, color: AppColors.textMuted),
              const SizedBox(height: 20),
              const Text('You are not logged in',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Log In / Sign Up'),
              ),
            ],
          ),
        ),
      );
    }

    final user = auth.appUser!;
    final bookings = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    children: [
                      // Back button row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _signOut,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.error, width: 1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.logout,
                                      size: 16, color: AppColors.error),
                                  SizedBox(width: 6),
                                  Text('Sign Out',
                                      style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Avatar
                      CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            AppColors.accent.withValues(alpha: 0.2),
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.displayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: user.isOrganizer
                              ? AppColors.organizerAccent
                                  .withValues(alpha: 0.2)
                              : AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: user.isOrganizer
                                ? AppColors.organizerAccent
                                : AppColors.accent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          user.isOrganizer ? '🏢 Organizer' : '🎟 User',
                          style: TextStyle(
                            color: user.isOrganizer
                                ? AppColors.organizerLight
                                : AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Quick Actions ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone number info row
                  if (user.phone.isNotEmpty)
                    _InfoRow(icon: Icons.phone_outlined, label: user.phone),

                  // Organizer dashboard link
                  if (user.isOrganizer) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed('/organizer_dashboard'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.organizerGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.dashboard, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Organizer Dashboard',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text('Manage events & bookings',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text(
                    'My Bookings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Bookings List ──────────────────────────────────────
          if (bookings.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accent)),
              ),
            )
          else if (bookings.bookings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.confirmation_number_outlined,
                          size: 56,
                          color: AppColors.accent.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const Text('No bookings yet',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/home'),
                        child: const Text('Browse Events'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = bookings.bookings[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.surfaceVariant, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.eventName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: booking.isPaid
                                      ? AppColors.success
                                          .withValues(alpha: 0.15)
                                      : AppColors.warning
                                          .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  booking.status.name.toUpperCase(),
                                  style: TextStyle(
                                      color: booking.isPaid
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 14,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text('${booking.quantity} ticket(s)',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                              const Spacer(),
                              Text(
                                'Rs. ${booking.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy · hh:mm a')
                                .format(booking.bookingDate),
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: bookings.bookings.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
