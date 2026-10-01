// lib/screens/home_screen.dart
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    final auth = context.read<app_auth.AuthProvider>();
    if (!auth.isSignedIn) {
      Navigator.of(context).pushNamed('/login');
    } else if (auth.role == UserRole.organizer) {
      Navigator.of(context).pushNamed('/organizer_dashboard');
    } else {
      Navigator.of(context).pushNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            snap: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
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
                        // Profile / Auth Icon
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

          // ── Search Bar ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: ticketProvider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search events, venues, artists…',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
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

          // ── Category Filter Chips ─────────────────────────────
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
                      ticketProvider.selectedCategory == cat;
                  return GestureDetector(
                    onTap: () =>
                        ticketProvider.setCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
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

          // ── Organizer quick-link banner (if user is organizer) ─
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

          // ── Section Label ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticketProvider.selectedCategory == 'All'
                        ? 'All Events'
                        : ticketProvider.selectedCategory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

          // ── Events Content ────────────────────────────────────
          if (ticketProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent)),
            )
          else if (ticketProvider.events.isEmpty)
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
