// lib/screens/profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// ProfileScreen | පරිශීලක පැතිකඩ තිරය (User Profile Screen)
// Displays logged-in user profile info and their personal ticket booking history.
// ලොග් වී සිටින පරිශීලකයාගේ පැතිකඩ තොරතුරු සහ ප්‍රවේශපත්‍ර වෙන්කිරීම් ඉතිහාසය පෙන්වයි.
// Handles three authentication/loading states:
//   1. Unauthenticated (Sign In prompt) | ලොග් වී නැති (Sign In ඇතුල්වීමේ තිරය)
//   2. Loading state (Progress indicator) | දත්ත පූරණය වන අවස්ථාව (Loading indicator)
//   3. Authenticated (Profile details + Bookings) | ලොග් වී ඇති (විස්තර + වෙන්කිරීම්)
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/color_palette.dart';

// ─── ProfileScreen Widget | ProfileScreen විජට් එක ───────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ─── initState: Lifecycle initialization | initState: ජීවන චක්‍රය ආරම්භක අවස්ථාව ──
  // Triggers user bookings fetch immediately after the widget is laid out.
  // විජට් එක තිරයේ සකස් වූ වහාම පරිශීලකයාගේ වෙන්කිරීම් දත්ත ලබා ගැනීම සිදු කරයි.
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback - executes after the build phase finishes to avoid provider errors
    // addPostFrameCallback - build පියවර අවසන් වූ පසු ධාවනය වේ (provider දෝෂ වළක්වා ගැනීමට)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      // Query bookings only if the user is authenticated with Firebase
      // Firebase හරහා පරිශීලකයා ලොග් වී ඇත්නම් පමණක් bookings ලබා ගනී
      if (auth.isSignedIn && auth.firebaseUser != null) {
        context
            .read<BookingProvider>()
            .loadUserBookings(auth.firebaseUser!.uid);
      }
    });
  }

  // ─── _signOut: Handle user logout session | _signOut: ගිණුමෙන් ඉවත් වීමේ ක්‍රියාවලිය ─
  // Confirms with dialog, clears local states, calls AuthProvider to sign out.
  // Dialog එකකින් තහවුරු කර, local states මකා දමා, AuthProvider මඟින් ඉවත් කරයි.
  Future<void> _signOut() async {
    // Show AlertDialog confirmation box | AlertDialog තහවුරු කිරීමේ කොටුව පෙන්වයි
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          // Cancel button | අවලංගු කිරීමේ බොත්තම
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          // Logout button | ඉවත් වීමේ බොත්තම
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    // If confirmed, execute cleaning and auth sign out
    // තහවුරු කළේ නම්, දත්ත මකා දමා ගිණුමෙන් ඉවත් වීම ධාවනය කරයි
    if (confirmed == true && mounted) {
      // Clear bookings in BookingProvider | BookingProvider හි වෙන්කිරීම් ඉවත් කරයි
      context.read<BookingProvider>().clear();
      // Call sign out on AuthProvider | AuthProvider මඟින් sign out කරයි
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        // Redirect user back to home route | පරිශීලකයා නැවත home පිටුවට යොමු කරයි
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  // ─── build: Renders UI based on Auth State | build: Auth තත්වය අනුව UI පෙන්වයි ──
  @override
  Widget build(BuildContext context) {
    // Watch AuthProvider for real-time authentication updates
    // සජීවී authentication වෙනස්කම් සඳහා AuthProvider watch කරයි
    final auth = context.watch<AuthProvider>();

    // ── STATE 1: Unauthenticated | 1 වන අවස්ථාව: ලොග් වී නොමැති විට ───────────────
    // Display login promotion banner with direct redirect button
    // Login වීමට යෝජනා කරන පණිවිඩය සහ ඊට අදාළ බොත්තම පෙන්වයි
    if (!auth.isSignedIn) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined,
                  size: 80, color: AppColors.textMuted),
              const SizedBox(height: 20),
              const Text('You are not logged in',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 18)),
              const SizedBox(height: 16),
              // Button directing to login screen | Login පිටුවට යන බොත්තම
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Log In / Sign Up'),
              ),
            ],
          ),
        ),
      );
    }

    // ── STATE 2: Loading Status | 2 වන අවස්ථාව: දත්ත පූරණය වන විට ──────────────────
    // Displayed while fetching profile or authentication changes
    // පැතිකඩ තොරතුරු හෝ auth වෙනස්කම් පූරණය වන විට පෙන්වයි
    if (auth.isLoading ||
        (auth.isSignedIn && auth.appUser == null && auth.error == null)) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final user = auth.appUser;
    // Watch BookingProvider to react to booking list changes in real-time
    // Booking ලැයිස්තුවේ වෙනස්කම් සජීවීව යාවත්කාලීන කිරීමට BookingProvider watch කරයි
    final bookings = context.watch<BookingProvider>();

    // ── ERROR STATE: Auth valid but User profile missing from Firestore ──────
    // Happens if Firestore user document wasn't created or got deleted.
    // Firestore හි user document එකක් නොමැති විට හෝ මැකී ඇති විට මෙය සිදු වේ.
    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 80, color: AppColors.error),
                const SizedBox(height: 20),
                Text(auth.error ?? 'Could not load profile data.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 24),
                // Sign out button fallback | fallback ලෙස sign out වීමේ බොත්තම
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Option to delete orphaned credentials | orphaned ගිණුම ස්ථිරවම මකා දැමීම
                TextButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().deleteAccount();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Orphaned Account'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── STATE 3: Authenticated UI | 3 වන අවස්ථාව: සාර්ථකව ඇතුළු වී ඇති විට ─────────
    // Renders custom scroll view displaying user profile headers and bookings lists.
    // පරිශීලක පැතිකඩ තොරතුරු සහ වෙන්කිරීම් ලැයිස්තුව scroll view එකකින් පෙන්වයි.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── Sliver 1: User Profile Header | sliver 1: පරිශීලක පැතිකඩ ශීර්ෂය ───────
          SliverToBoxAdapter(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    children: [
                      // Navigation and session rows | Navigation සහ logout බොත්තම
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
                      // Circular avatar with initials | පරිශීලක මුලකුරු සහිත avatar එක
                      CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            AppColors.accent.withValues(alpha: 0.2),
                        child: Text(user.initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 14),
                      // User full display name | පරිශීලකයාගේ සම්පූර්ණ නම
                      Text(user.displayName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      // Registered email address | ලියාපදිංචි විද්‍යුත් තැපෑල (Email)
                      Text(user.email,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 8),
                      // Organizer or regular user role status badge
                      // Organizer හෝ සාමාන්‍ය පරිශීලක (User) තත්ව ලේබලය
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: user.isOrganizer
                              ? AppColors.organizerAccent.withValues(alpha: 0.2)
                              : AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: user.isOrganizer
                                  ? AppColors.organizerAccent
                                  : AppColors.accent,
                              width: 1),
                        ),
                        child: Text(
                            user.isOrganizer ? '🏢 Organizer' : '🎟 User',
                            style: TextStyle(
                                color: user.isOrganizer
                                    ? AppColors.organizerLight
                                    : AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Sliver 2: Contact info & Dashboard redirect button ───────────────────
          // ─── sliver 2: සම්බන්ධතා තොරතුරු සහ dashboard යොමු කිරීමේ බොත්තම් ──────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact phone information row | සම්බන්ධතා දුරකථන අංකය පෙන්වන පේළිය
                  if (user.phone.isNotEmpty)
                    _InfoRow(icon: Icons.phone_outlined, label: user.phone),
                  // Link to organizer dashboard page | organizer dashboard පිටුවට යන බොත්තම
                  if (user.isOrganizer) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed('/organizer_dashboard'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            gradient: AppColors.organizerGradient,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Row(
                          children: [
                            Icon(Icons.dashboard, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                                child: Text('Organizer Dashboard',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))),
                            Icon(Icons.chevron_right, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // ─── Theme Switcher | තේමා සැකසුම් ───────────────────────────
                  Text('App Settings',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Theme.of(context).dividerTheme.color ??
                                Colors.transparent)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.dark_mode_outlined,
                                color: Theme.of(context).colorScheme.onSurface),
                            const SizedBox(width: 12),
                            Text('Dark Mode',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Switch(
                          value: context.watch<ThemeProvider>().isDarkMode,
                          onChanged: (val) =>
                              context.read<ThemeProvider>().toggleTheme(val),
                          activeThumbColor: AppColors.accent,
                          activeTrackColor:
                              AppColors.accent.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Bookings section heading | වෙන්කිරීම් කොටසේ ශීර්ෂය
                  Text('My Bookings',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // ─── Sliver 3: User Bookings Lists | sliver 3: පරිශීලක වෙන්කිරීම් ලැයිස්තුව ────
          if (bookings.isLoading)
            // Show loader while loading booking records | වෙන්කිරීම් පූරණය වන විට පෙන්වන loader එක
            const SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent))))
          else if (bookings.bookings.isEmpty)
            // Empty bookings history state | වෙන්කිරීම් නොමැති විට පෙන්වන හිස් තත්වය
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.confirmation_number_outlined,
                          size: 56,
                          color: AppColors.accent.withValues(alpha: 0.3)),
                      const Text('No bookings yet',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16)),
                      TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/home'),
                          child: const Text('Browse Events')),
                    ],
                  ),
                ),
              ),
            )
          else
            // Render booking cards list using SliverList
            // SliverList මඟින් වෙන්කිරීම් ලැයිස්තුව කාඩ්පත් ලෙස දක්වයි
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = bookings.bookings[index];
                    // ── Render single booking record card | වෙන්කිරීම් පත (Card) ───────
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.surfaceVariant, width: 1)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Ticket event name text | ප්‍රවේශපත්‍ර සිදුවීමේ නම
                              Expanded(
                                  child: Text(booking.eventName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15))),
                              // Paid or Pending booking status label
                              // ගෙවන ලද (PAID) හෝ පොරොත්තු (PENDING) තත්ව ලේබලය
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: booking.isPaid
                                        ? AppColors.success
                                            .withValues(alpha: 0.15)
                                        : AppColors.warning
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(booking.status.name.toUpperCase(),
                                    style: TextStyle(
                                        color: booking.isPaid
                                            ? AppColors.success
                                            : AppColors.warning,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number_outlined,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              // Booked tickets quantity | වෙන්කර ඇති ප්‍රවේශපත්‍ර ගණන
                              Text('${booking.quantity} ticket(s)',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                              const Spacer(),
                              // Total purchase price in LKR | මුළු ගෙවීම් මුදල
                              Text(
                                  'Rs. ${booking.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ],
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

// ─── _InfoRow Widget: Compact icon-label visual row ──────────────────────────
// ─── _InfoRow විජට්: අයිකන සහ ලේබල් පේළියක් පෙන්වන කුඩා විජට් එක ──────────────
class _InfoRow extends StatelessWidget {
  final IconData icon; // Icon to display | පෙන්වන අයිකනය
  final String label; // String text label | පෙන්වන ලේබල් පෙළ
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
