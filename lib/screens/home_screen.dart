// lib/screens/home_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen | ගෙදර තිරය (Main Discovery Screen)
// The primary screen where users browse all published events.
// Features a collapsing hero app bar, real-time search, category filter chips,
// an organizer quick-link banner, a section count label, and the event list.
// සිදුවීම් ගවේෂණය කිරීමේ ප්‍රධාන තිරය.
// හෙරෝ AppBar, සෙවීම, ප්‍රවර්ග ෆිල්ටර, සංවිධායක banner, සහ සිදුවීම් ලැයිස්තුව ඇත.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/ticket_provider.dart';
import '../models/user.dart';
import '../widgets/ticket_card.dart';
import '../theme/color_palette.dart';
import 'ticket_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Search text controller | සෙවීම් ආදාන පාලකය
  final _searchController = TextEditingController();

  @override
  void dispose() {
    // Release search controller memory | සෙවීම් පාලකයේ මතකය නිදහස් කරයි
    _searchController.dispose();
    super.dispose();
  }

  // ─── _navigateToProfile: Routes to the right screen based on auth state ──
  // _navigateToProfile: ප්‍රමාණීකරණ (auth) තත්වය අනුව නිවැරදි ප්‍රොෆයිල් තිරයට
  void _navigateToProfile() {
    final auth = context.read<app_auth.AuthProvider>();
    if (!auth.isSignedIn) {
      Navigator.of(context).pushNamed('/login');       // Not signed in → login | ලොගිනය නොකළ → ලොගිනය
    } else if (auth.role == UserRole.organizer) {
      Navigator.of(context).pushNamed('/organizer_dashboard'); // Organizer → dashboard
    } else {
      Navigator.of(context).pushNamed('/profile');     // User → profile | පරිශීලකයා → ප්‍රොෆයිල්
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth and ticket providers for reactive rebuilds
    // ප්‍රතික්‍රියාශීලී නැවත ගොඩනිව්ම සඳහා auth සහ ticket providers නිරීක්ෂණය
    final auth = context.watch<app_auth.AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar: Collapses on scroll ──────────────────────
          // ── Hero SliverAppBar: අනුචලනයේදී හකුළේ ─────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: true,   // Snaps back into view on scroll up | ඉහළ අනුචලනයේදී නැවත පෙනේ
            snap: true,       // Snaps fully open or closed | සම්පූර්ණ විවෘත/වසා snap වේ
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient, // Dark blue gradient | තද නිල් gradient
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // App brand label | යෙදුම් ලාංජන ලේබලය
                              const Text(
                                'MyTickets.lk',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Personalized greeting if signed in, else generic
                              // ලොගිනය කළේ නම් පෞද්ගලිකිකෘත ආදරාමී, නැතිනම් සාමාන්‍ය
                              Text(
                                auth.isSignedIn
                                    ? 'Hi, ${auth.appUser?.displayName ?? 'there'} 👋'
                                    : 'Discover Events',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Find your next unforgettable experience',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // Profile avatar / login icon button
                        // ප්‍රොෆයිල් avatar / ලොගිනය නිරූපකය
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.accent, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  AppColors.accent.withValues(alpha: 0.2),
                              // Show initials if signed in, else person icon
                              // ලොගිනය කළේ නම් මූලාක්ෂර, නැතිනම් person icon
                              child: auth.isSignedIn
                                  ? Text(
                                      auth.appUser?.initials ?? 'U',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    )
                                  : const Icon(Icons.person,
                                      color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Search Bar: Triggers TicketProvider search filter ───────────
          // ── සෙවීම් තීරුව: TicketProvider සෙවීම් ෆිල්ටරය ක්‍රියාත්මක කරයි ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                // Pipes text to provider on each keystroke | සෑම keystroke එකේදීම provider ට යවයි
                onChanged: ticketProvider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search events, venues, artists…',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
                  // Clear button appears only when there is text
                  // පෙළ ඇත්නම් පමණක් Clear (×) බොත්තම දිස්වේ
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ticketProvider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Category Filter Chips: Horizontal scrollable chip row ────────
          // ── ප්‍රවර්ග ෆිල්ටර් Chips: තිරස් අනුචලන chip රේඛාව ───────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: TicketProvider.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = TicketProvider.categories[index];
                  final selected =
                      ticketProvider.selectedCategories.contains(cat);
                  return GestureDetector(
                    onTap: () =>
                        ticketProvider.setCategory(cat), // Toggle category filter | ප්‍රවර්ගය ෆිල්ටරය ටොගල් කරයි
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        // Active: accent fill, inactive: surface variant
                        // ක්‍රියාශීලී: accent fill, අක්‍රිය: surface variant
                        color: selected
                            ? AppColors.accent
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Organizer Quick-Link Banner (visible only if organizer role) ─
          // ── සංවිධායක ඉක්මන් සබැඳිය banner (organizer role ඇත්නම් පමණ) ──
          if (auth.isSignedIn && auth.role == UserRole.organizer)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushNamed('/organizer_dashboard'),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppColors.organizerGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.business, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Go to Organizer Dashboard →',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Section Label: Shows category filter and event count ─────────
          // ── කොටස් ලේබලය: ප්‍රවර්ගය ෆිල්ටරය සහ සිදුවීම් ගණන ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Shows current filter label or "All Events"
                  // දැනට ඇති ෆිල්ටරය හෝ "All Events" ලේබලය
                  Text(
                    ticketProvider.selectedCategories.contains('All')
                        ? 'All Events'
                        : ticketProvider.selectedCategories.join(', '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Shows total count after loading completes | loading ඉවර වූ පසු ගණනය
                  if (!ticketProvider.isLoading)
                    Text(
                      '${ticketProvider.events.length} events',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                ],
              ),
            ),
          ),

          // ── Events Content: Loading / Empty / List ────────────────────────
          // ── සිදුවීම් අන්තර්ගතය: Loading / හිස් / ලැයිස්තුව ──────────────
          if (ticketProvider.isLoading)
            // Loading state: show centered spinner | Loading: spinner
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent)),
            )
          else if (ticketProvider.events.isEmpty)
            // Empty state: show icon and clear filter button
            // හිස් state: icon සහ ෆිල්ටර් ඉවත් කිරීමේ බොත්තම
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy,
                        size: 64,
                        color:
                            AppColors.accent.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    const Text(
                      'No events found',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        ticketProvider.clearFilters();
                      },
                      child: const Text('Clear filters'),
                    ),
                  ],
                ),
              ),
            )
          else
            // List of events: tapping opens TicketDetailScreen
            // සිදුවීම් ලැයිස්තුව: tap කළ විට TicketDetailScreen විවෘත කරයි
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final t = ticketProvider.events[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TicketDetailScreen(ticket: t),
                        ),
                      ),
                      child: TicketCard(ticket: t),
                    );
                  },
                  childCount: ticketProvider.events.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
