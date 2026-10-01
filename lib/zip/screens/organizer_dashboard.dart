// lib/screens/organizer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/organizer_provider.dart';
import '../models/ticket.dart';
import '../theme/color_palette.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() =>
      _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize organizer data once we have the auth user
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrganizer());
  }

  void _loadOrganizer() {
    final auth = context.read<AuthProvider>();
    final orgId = auth.appUser?.organizerId;
    if (orgId != null) {
      context.read<OrganizerProvider>().initialize(orgId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out',
            style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<OrganizerProvider>().clear();
      await context.read<AuthProvider>().signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _confirmDelete(String eventId, String eventName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Event',
            style: TextStyle(color: Colors.white)),
        content: Text('Delete "$eventName"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await context.read<OrganizerProvider>().deleteEvent(eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Event deleted' : 'Failed to delete event'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = context.watch<OrganizerProvider>();

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AppColors.organizerAccent,
          secondary: AppColors.organizerLight,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.organizerAccent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Organizer Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (org.organizer != null)
                Text(org.organizer!.name,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: _signOut),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(
                  text:
                      'Published (${org.publishedEventsCount})'),
              Tab(text: 'Drafts (${org.draftEvents.length})'),
            ],
          ),
        ),
        body: org.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.organizerAccent))
            : Column(
                children: [
                  // Stats header cards
                  _StatsBar(
                    totalEvents: org.totalEventsCount,
                    totalRevenue: org.totalRevenue,
                    totalAttendees: org.totalAttendees,
                  ),
                  // Event list tabs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _EventList(
                            events: org.publishedEvents,
                            onDelete: _confirmDelete,
                            onPublishToggle: (id) => context
                                .read<OrganizerProvider>()
                                .unpublishEvent(id),
                            isPublished: true),
                        _EventList(
                            events: org.draftEvents,
                            onDelete: _confirmDelete,
                            onPublishToggle: (id) => context
                                .read<OrganizerProvider>()
                                .publishEvent(id),
                            isPublished: false),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.organizerAccent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Create Event',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () =>
              Navigator.of(context).pushNamed('/create_event'),
        ),
      ),
    );
  }
}

// ─── Stats Bar ──────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final int totalEvents;
  final double totalRevenue;
  final int totalAttendees;

  const _StatsBar({
    required this.totalEvents,
    required this.totalRevenue,
    required this.totalAttendees,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: AppColors.organizerGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.organizerAccent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          _StatItem(
              icon: Icons.event,
              label: 'Events',
              value: totalEvents.toString()),
          _Divider(),
          _StatItem(
              icon: Icons.people,
              label: 'Attendees',
              value: totalAttendees.toString()),
          _Divider(),
          _StatItem(
              icon: Icons.monetization_on,
              label: 'Revenue',
              value: 'Rs.${(totalRevenue / 1000).toStringAsFixed(1)}K'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 36,
        width: 1,
        color: Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 4));
  }
}

// ─── Event List ──────────────────────────────────────────────────────────────
class _EventList extends StatelessWidget {
  final List<Ticket> events;
  final void Function(String id, String name) onDelete;
  final Future<bool> Function(String id) onPublishToggle;
  final bool isPublished;

  const _EventList({
    required this.events,
    required this.onDelete,
    required this.onPublishToggle,
    required this.isPublished,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note,
                size: 64,
                color: AppColors.organizerAccent.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              isPublished
                  ? 'No published events yet'
                  : 'No draft events',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + Create Event to add one',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _OrganizerEventCard(
          event: event,
          onDelete: () => onDelete(event.id, event.eventName),
          onPublishToggle: () => onPublishToggle(event.id),
          isPublished: isPublished,
        );
      },
    );
  }
}

// ─── Organizer Event Card ────────────────────────────────────────────────────
class _OrganizerEventCard extends StatelessWidget {
  final Ticket event;
  final VoidCallback onDelete;
  final VoidCallback onPublishToggle;
  final bool isPublished;

  const _OrganizerEventCard({
    required this.event,
    required this.onDelete,
    required this.onPublishToggle,
    required this.isPublished,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy · hh:mm a').format(event.eventDate);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPublished
              ? AppColors.organizerAccent.withValues(alpha: 0.3)
              : AppColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.eventName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPublished
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPublished ? 'Live' : 'Draft',
                    style: TextStyle(
                      color: isPublished
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.venue,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Rs. ${event.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.organizerAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(width: 8),
                Text(
                  '· ${event.availableSeats} seats',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                ),
                const Spacer(),
                // Publish / Unpublish toggle button
                TextButton.icon(
                  onPressed: onPublishToggle,
                  icon: Icon(
                    isPublished
                        ? Icons.visibility_off_outlined
                        : Icons.publish,
                    size: 16,
                  ),
                  label: Text(
                    isPublished ? 'Unpublish' : 'Publish',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: isPublished
                        ? AppColors.textMuted
                        : AppColors.organizerAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                  ),
                ),
                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.error),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
