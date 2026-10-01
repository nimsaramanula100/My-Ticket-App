// lib/screens/organizer_dashboard.dart
// ─────────────────────────────────────────────────────────────────────────────
// OrganizerDashboardScreen | සංවිධායක ප්‍රධාන පුවරුව (Organizer Dashboard)
// Main management hub for event organizers.
// Shows a tabbed view of Published vs Draft events, a stats bar (events/attendees/revenue),
// and per-event cards with publish toggle, delete, and edit actions.
// සිදුවීම් සංවිධායකයන් සඳහා ප්‍රධාන කළමනාකරණ center.
// Published සහ Draft සිදුවීම්, stats bar, සහ ටොගල්/delete/edit ක්‍රියා සහිත event cards.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/organizer_provider.dart';
import '../providers/theme_provider.dart';
import '../models/ticket.dart';
import '../theme/color_palette.dart';
import '../theme/app_theme.dart';
import 'event_details_editor_screen.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() =>
      _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Manages Published / Drafts tabs | Published / Drafts ටැබ් කළමනාකරණය

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load organizer data after first frame so BuildContext is available
    // BuildContext ලබා ගත හැකි වීමෙන් පසු organizer දත්ත ලෝඩ් කරයි
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrganizer());
  }

  // ─── _loadOrganizer: Initialize OrganizerProvider with the logged-in org ID ──
  // _loadOrganizer: ලොගිනය කළ org ID සමඟ OrganizerProvider initialize කරයි
  void _loadOrganizer() {
    final auth = context.read<AuthProvider>();
    final orgId = auth.appUser?.organizerId;
    if (orgId != null) {
      context.read<OrganizerProvider>().initialize(orgId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // Release tab controller | ටැබ් පාලකය නිදහස් කරයි
    super.dispose();
  }

  // ─── _signOut: Confirm dialog → clear state → sign out → home ──────────
  // _signOut: තහවුරු dialog → state නිර්මල → sign out → home
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
      context.read<OrganizerProvider>().clear(); // Clear organizer state | සංවිධායක state නිර්මල
      await context.read<AuthProvider>().signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    }
  }

  // ─── _confirmDelete: Confirm dialog → delete event from Firestore ───────
  // _confirmDelete: තහවුරු dialog → Firestore හි event delete කරයි
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
        // Show success or failure snackbar | සාර්ථකත්ව හෝ අසාර්ථකත්ව Snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Event deleted' : 'Failed to delete event'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch OrganizerProvider for reactive state updates
    // ප්‍රතික්‍රියාශීලී state updates සඳහා OrganizerProvider නිරීක්ෂණය
    final org = context.watch<OrganizerProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Theme(
      // Use the full Organizer Theme based on the current mode
      // පවතින තේමා මාදිලිය අනුව සම්පූර්ණ Organizer Theme භාවිතා කරයි
      data: isDark ? AppTheme.organizerDarkTheme() : AppTheme.organizerLightTheme(),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.organizerAccent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Organizer Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Organizer company name subtitle | සංවිධා නාමය subtitle
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
            // Tab labels show live counts | ටැබ් ලේබල් සජීවී ගණන් පෙන්වයි
            tabs: [
              Tab(text: 'Published (${org.publishedEventsCount})'),
              Tab(text: 'Drafts (${org.draftEvents.length})'),
            ],
          ),
        ),
        // Show full-screen spinner while data is loading
        // දත්ත ලෝඩ් වන අතරතුර සම්පූර්ණ-තිර spinner
        body: org.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.organizerAccent))
            : Column(
                children: [
                  // ── Stats summary bar | ── සංඛ්‍යාලේඛන සාරාංශ තීරුව ──────
                  _StatsBar(
                    totalEvents: org.totalEventsCount,
                    totalRevenue: org.totalRevenue,
                    totalAttendees: org.totalAttendees,
                  ),
                  // ── Tabbed event list | ── ටැබ් සිදුවීම් ලැයිස්තුව ──────
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Published events tab | ප්‍රකාශිත සිදුවීම් ටැබ්
                        _EventList(
                            events: org.publishedEvents,
                            onDelete: _confirmDelete,
                            onPublishToggle: (id) => context
                                .read<OrganizerProvider>()
                                .unpublishEvent(id),
                            isPublished: true),
                        // Draft events tab | ෂ draft සිදුවීම් ටැබ්
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
        // FAB to navigate to Create Event screen | Create Event ස්ක්‍රීනයට යෙදෙන FAB
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

// ─── _StatsBar: Horizontal KPI banner with 3 metrics ─────────────────────────
// _StatsBar: KPI metrics 3 ක් සහිත තිරස් සංඛ්‍යාලේඛන banner
class _StatsBar extends StatelessWidget {
  final int totalEvents;     // Total event count | සමස්ත සිදුවීම් ගණන
  final double totalRevenue; // Aggregated revenue | සමස්ත ආදායම
  final int totalAttendees;  // Total attendees | සමස්ත සහභාගිවන්නන්

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
          _Divider(), // Vertical divider between stats | Stats අතර සිරස් divider
          _StatItem(
              icon: Icons.people,
              label: 'Attendees',
              value: totalAttendees.toString()),
          _Divider(),
          _StatItem(
              icon: Icons.monetization_on,
              label: 'Revenue',
              // Format in thousands (K) for compactness | සංක්ෂිප්තතාවය සඳහා K ආකෘතිය
              value: 'Rs.${(totalRevenue / 1000).toStringAsFixed(1)}K'),
        ],
      ),
    );
  }
}

// ─── _StatItem: Single metric cell in the stats bar ─────────────────────────
// _StatItem: Stats bar තුළ තනි metric cell
class _StatItem extends StatelessWidget {
  final IconData icon;  // Metric icon | metric නිරූපකය
  final String label;   // Metric label | metric ලේබලය
  final String value;   // Formatted value | හැඩගන්වන ලද අගය

  const _StatItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          // Large bold value | විශාල bold අගය
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          // Smaller label below | පහළ කුඩා ලේබලය
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}

// ─── _Divider: Thin vertical separator between stat cells ─────────────────────
// _Divider: Stat cells අතර얇은 සිරස් separator
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

// ─── _EventList: Renders the list for a given tab ─────────────────────────────
// _EventList: දී ඇති ටැබ් සඳහා ලැයිස්තුව render කරයි
class _EventList extends StatelessWidget {
  final List<Ticket> events;                            // Events to display | පෙන්විය යුතු සිදුවීම්
  final void Function(String id, String name) onDelete; // Delete callback | Delete ශ්‍රිතය
  final Future<bool> Function(String id) onPublishToggle; // Publish/Unpublish toggle | ප්‍රකාශ ටොගලය
  final bool isPublished;                               // Whether tab shows published | Published ටැබ් දැයි

  const _EventList({
    required this.events,
    required this.onDelete,
    required this.onPublishToggle,
    required this.isPublished,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state message | හිස් state message
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

    // Render scrollable list of event cards | Scroll කළ හැකි event card ලැයිස්තුව
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

// ─── _OrganizerEventCard: Per-event card with management actions ─────────────
// _OrganizerEventCard: කළමනාකරණ ක්‍රියා සහිත event-per-card
class _OrganizerEventCard extends StatelessWidget {
  final Ticket event;              // Event data | සිදුවීම් දත්ත
  final VoidCallback onDelete;     // Delete action | Delete ක්‍රියාව
  final VoidCallback onPublishToggle; // Publish/Unpublish action | ප්‍රකාශ ටොගල් ක්‍රියාව
  final bool isPublished;          // Current publish state | දැනට ඇති ප්‍රකාශ state

  const _OrganizerEventCard({
    required this.event,
    required this.onDelete,
    required this.onPublishToggle,
    required this.isPublished,
  });

  @override
  Widget build(BuildContext context) {
    // Format date/time for display | දිස්ප්ලේ සඳහා දිනය/වේලාව හැඩගන්වයි
    final dateStr =
        DateFormat('dd MMM yyyy · hh:mm a').format(event.eventDate);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Published events have a tinted accent border | Published events accent border
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
                // Event name (truncated) | සිදුවීමේ නම (කෙටි)
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
                // Live / Draft badge | Live / Draft badge
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
            // Venue row | ස්ථාන රේඛාව
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
            // Date & time row | දිනය සහ වේලාව රේඛාව
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
                // Price display | මිල ප්‍රදර්ශනය
                Text(
                  'Rs. ${event.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.organizerAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(width: 8),
                // Seat count | ආසන ගණන
                Text(
                  '· ${event.availableSeats} seats',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                ),
                const Spacer(),
                // Publish / Unpublish toggle | ප්‍රකාශ / අප්‍රකාශ ටොගලය
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
                // Delete icon button | Delete නිරූපකය
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.error),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Edit Ticket Page Details button — navigates to EventDetailsEditorScreen
            // ප්‍රවේශපත්‍ර පිටු විස්තර සංස්කරණ බොත්තම — EventDetailsEditorScreen ට
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          EventDetailsEditorScreen(event: event),
                    ),
                  );
                },
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Edit Ticket Page Details',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.organizerAccent,
                  side: BorderSide(
                      color:
                          AppColors.organizerAccent.withValues(alpha: 0.5)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
