// lib/screens/event_details_editor_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// EventDetailsEditorScreen | සිදුවීම් විස්තර සංස්කරණ තිරය (Event Details Editor)
// Organizer screen to customize and publish the 5 display sections:
//   1. Available Deals    — ලබා ගත හැකි ගනුදෙනු (promo codes)
//   2. Available Payment Methods — ගෙවීම් ක්‍රම
//   3. More Information   — වැඩිදුර තොරතුරු
//   4. Booking Policy     — වෙන්කරවා ගැනීමේ ප්‍රතිපත්තිය
//   5. Organizer Details  — සංවිධායක විස්තර
// Changes are saved via FirestoreService.updateEvent() and the editor pops
// with `true` to signal the caller to refresh the dashboard.
// FirestoreService.updateEvent() හරහා සාදා caller dashboard refresh කරනු ලැබේ.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/firestore_service.dart';
import '../theme/color_palette.dart';

class EventDetailsEditorScreen extends StatefulWidget {
  final Ticket event; // Event to be edited | සංස්කරණය කළ යුතු සිදුවීම

  const EventDetailsEditorScreen({super.key, required this.event});

  @override
  State<EventDetailsEditorScreen> createState() =>
      _EventDetailsEditorScreenState();
}

// SingleTickerProviderStateMixin supplies vsync for the TabController
// TabController සඳහා vsync ලබා ගැනීමට SingleTickerProviderStateMixin
class _EventDetailsEditorScreenState extends State<EventDetailsEditorScreen>
    with SingleTickerProviderStateMixin {
  // ─── Tab Controller | ටැබ් පාලකය ──────────────────────────────────────────
  late TabController _tabController; // 5 tabs total | ටැබ් 5 ක්
  bool _saving = false; // Prevents concurrent save requests | සමකාලීන save requests වළකිනය

  // ─── Tab 1: Deals Controllers | ටැබ් 1: ගනුදෙනු පාලක ─────────────────────
  late TextEditingController _dealTitleCtrl;  // Deal/promo title | ගනුදෙනු/promo මාතෘකාව
  late TextEditingController _dealDescCtrl;   // Deal description | ගනුදෙනු විස්තරය

  // ─── Tab 2: Payment Methods | ටැබ් 2: ගෙවීම් ක්‍රම ─────────────────────────
  final List<String> _allMethods = ['Visa', 'Mastercard', 'Koko', 'PayHere', 'Bank Transfer', 'Cash on Door'];
  late List<String> _selectedMethods; // Currently selected methods | දැනට තෝරාගත් ක්‍රම

  // ─── Tab 3: More Info | ටැබ් 3: වැඩිදුර තොරතුරු ─────────────────────────
  late TextEditingController _moreInfoCtrl; // Full event description | සම්පූර්ණ සිදුවීම් විස්තරය

  // ─── Tab 4: Booking Policy | ටැබ් 4: ප්‍රතිපත්තිය ─────────────────────────
  late TextEditingController _bookingPolicyCtrl;  // Custom policy text | අභිරුචි ප්‍රතිපත්ති
  bool _useDefaultPolicy = true; // If true shows system default policy | true නම් පද්ධති ප්‍රතිපත්තිය

  // ─── Tab 5: Organizer Details | ටැබ් 5: සංවිධායක විස්තර ─────────────────────
  late TextEditingController _orgAboutCtrl; // About the organizer | සංවිධායකයා ගැන
  late TextEditingController _orgPhoneCtrl; // Organizer phone | සංවිධායකයාගේ දූ
  late TextEditingController _orgEmailCtrl; // Organizer email | සංවිධායකයාගේ ඊමේල්

  @override
  void initState() {
    super.initState();
    // Create TabController with 5 tabs (one per editor section)
    // Editor sections 5 ක් සඳහා TabController ගොඩනඟයි
    _tabController = TabController(length: 5, vsync: this);

    // Pre-fill all controllers with current event data
    // සියළු controllers වත්මන් event දත්ත සමඟ පූරව-පිරවීම
    final e = widget.event;
    _dealTitleCtrl = TextEditingController(text: e.dealTitle);
    _dealDescCtrl = TextEditingController(text: e.dealDescription);
    _selectedMethods = List<String>.from(e.paymentMethods);

    // Default to event description if moreInformation is empty
    // moreInformation හිස් නම් event description default ලෙස
    _moreInfoCtrl = TextEditingController(
        text: e.moreInformation.isNotEmpty
            ? e.moreInformation
            : e.eventDescription);
    _bookingPolicyCtrl =
        TextEditingController(text: e.customBookingPolicy);
    // If no custom policy exists, use the default system policy
    // අභිරුචි ප්‍රතිපත්තිය නොමැතිනම් පද්ධති ප්‍රතිපත්තිය
    _useDefaultPolicy = e.customBookingPolicy.isEmpty;
    _orgAboutCtrl = TextEditingController(text: e.organizerAbout);
    _orgPhoneCtrl = TextEditingController(text: e.organizerPhone);
    _orgEmailCtrl = TextEditingController(text: e.organizerEmail);
  }

  @override
  void dispose() {
    // Dispose all controllers and TabController to free memory
    // සියළු controllers සහ TabController dispose කරයි
    _tabController.dispose();
    _dealTitleCtrl.dispose();
    _dealDescCtrl.dispose();
    _moreInfoCtrl.dispose();
    _bookingPolicyCtrl.dispose();
    _orgAboutCtrl.dispose();
    _orgPhoneCtrl.dispose();
    _orgEmailCtrl.dispose();
    super.dispose();
  }

  // ─── _saveAndPublish: Collects all tab data and updates Firestore ────────
  // _saveAndPublish: සියළු ටැබ් දත්ත එකතු කර Firestore update කරයි
  Future<void> _saveAndPublish() async {
    if (_saving) return; // Guard: prevent double execution | ද්විත්ව ක්‍රියාත්මකවීම වළකිනය
    setState(() => _saving = true);
    try {
      // Collect all editor fields into a single update map
      // සියළු editor fields එකතු කර update map හදයි
      final data = <String, dynamic>{
        'dealTitle': _dealTitleCtrl.text.trim(),
        'dealDescription': _dealDescCtrl.text.trim(),
        'paymentMethods': _selectedMethods,
        'moreInformation': _moreInfoCtrl.text.trim(),
        // Empty string = use default system policy | හිස් = පද්ධති ප්‍රතිපත්තිය
        'customBookingPolicy':
            _useDefaultPolicy ? '' : _bookingPolicyCtrl.text.trim(),
        'organizerAbout': _orgAboutCtrl.text.trim(),
        'organizerPhone': _orgPhoneCtrl.text.trim(),
        'organizerEmail': _orgEmailCtrl.text.trim(),
      };

      // Push update to Firestore using the event's ID
      // event ID භාවිතා කර Firestore ට update push කරයි
      await FirestoreService().updateEvent(widget.event.id, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅  Event details saved & published!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Pop with `true` to signal the dashboard to reload
        // dashboard reload කරන ලෙස signal ලෙස `true` සමඟ pop
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030F26),
      appBar: AppBar(
        backgroundColor: AppColors.organizerAccent,
        // AppBar title shows screen title + event name as subtitle
        // AppBar title → screen මාතෘකාව + subtitle → event නාමය
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Event Details',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text(
              widget.event.eventName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // AppBar Save action: spinner while saving, button otherwise
          // AppBar Save action: saving අතරතුර spinner, නැතිනම් බොත්තම
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)))
              : TextButton.icon(
                  onPressed: _saveAndPublish,
                  icon: const Icon(Icons.publish,
                      color: Colors.white, size: 18),
                  label: const Text('Save & Publish',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
        ],
        // 5 scrollable tabs | Scroll කළ හැකි ටැබ් 5
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: '🏷️  Deals'),
            Tab(text: '💳  Payment'),
            Tab(text: 'ℹ️  Info'),
            Tab(text: '📋  Policy'),
            Tab(text: '🏢  Organizer'),
          ],
        ),
      ),
      // Each tab corresponds to one section builder below
      // ටැබ් එකක් section builder ශ්‍රිතයකට අනුරූප වේ
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDealsTab(),        // Tab 1 | ටැබ් 1
          _buildPaymentTab(),      // Tab 2 | ටැබ් 2
          _buildMoreInfoTab(),     // Tab 3 | ටැබ් 3
          _buildPolicyTab(),       // Tab 4 | ටැබ් 4
          _buildOrganizerTab(),    // Tab 5 | ටැබ් 5
        ],
      ),
      // Persistent save bar at the bottom (mirrors AppBar action)
      // පහළ ස්ථාවර save bar (AppBar action වලට සමාන)
      bottomNavigationBar: _buildSaveBar(),
    );
  }

  // ─── Bottom Save Bar ─────────────────────────────────────────────────────
  // ── පහළ Save Bar ─────────────────────────────────────────────────────────
  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0B172E),
        border:
            Border(top: BorderSide(color: Color(0xFF1E2E4E), width: 1)),
      ),
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _saveAndPublish,
        // Spinner while saving, upload icon otherwise
        // Saving අතරතුර spinner, නැතිනම් upload icon
        icon: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.cloud_upload_outlined),
        label: Text(_saving ? 'Saving…' : 'Save & Publish Changes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.organizerAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ─── Tab 1: Deals — Deal title and description with live preview ─────────
  // ── ටැබ් 1: ගනුදෙනු — සජීවී preview සහිත deal title සහ description ──────
  Widget _buildDealsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            '🏷️  Available Deals',
            'Add a promo code or discount that shows on the ticket page.',
          ),
          const SizedBox(height: 20),
          _editorCard(
            children: [
              _label('Deal / Promo Title'),
              const SizedBox(height: 8),
              _textField(
                controller: _dealTitleCtrl,
                hint: 'e.g. NEON MANTRA 25% OFF – Exclusive Promo Code',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _label('Deal Description'),
              const SizedBox(height: 8),
              _textField(
                controller: _dealDescCtrl,
                hint: 'e.g. Applicable deals will automatically take effect in the checkout page.',
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Live preview card — updates as user types
          // සජීවී preview card — user type කරන විට update වේ
          _previewCard(
            title: '🟢  Preview: Available Deals',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Text('Available Deals',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                // ValueListenableBuilder rebuilds only this text widget on changes
                // ValueListenableBuilder — text widget පමණ නැවත ගොඩනඟයි
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _dealTitleCtrl,
                  builder: (_, v, __) => Text(
                    v.text.isEmpty
                        ? 'Your deal title will appear here'
                        : v.text,
                    style: TextStyle(
                      color: v.text.isEmpty ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _dealDescCtrl,
                  builder: (_, v, __) => Text(
                    v.text.isEmpty ? 'Deal description...' : v.text,
                    style: TextStyle(
                        color: v.text.isEmpty
                            ? Colors.white24
                            : AppColors.textMuted,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 2: Payment Methods — Animated chip toggle grid ─────────────────
  // ── ටැබ් 2: ගෙවීම් ක්‍රම — ජීව්‍රිත chip ටොගල් grid ──────────────────────
  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            '💳  Available Payment Methods',
            'Select which payment methods to show on the ticket detail page.',
          ),
          const SizedBox(height: 20),
          _editorCard(
            children: [
              _label('Select accepted methods'),
              const SizedBox(height: 12),
              // Wrap allows chips to flow onto multiple lines
              // Wrap chips බහු රේඛාවල ගලා යාමට ඉඩ දෙයි
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _allMethods.map((method) {
                  final selected = _selectedMethods.contains(method);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          // Keep at least one payment method | අවම එක් ගෙවීම් ක්‍රමයක් රකිනය
                          if (_selectedMethods.length > 1) {
                            _selectedMethods.remove(method);
                          }
                        } else {
                          _selectedMethods.add(method);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.organizerAccent
                                .withValues(alpha: 0.2)
                            : const Color(0xFF0B172E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.organizerAccent
                              : const Color(0xFF1E2E4E),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: selected
                                ? AppColors.organizerAccent
                                : Colors.white38,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_paymentIcon(method)}  $method',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Preview of active chips | ක්‍රියාශීලී chips preview
          _previewCard(
            title: '🟢  Preview: Payment Methods',
            child: Wrap(
              spacing: 8,
              children: _selectedMethods.map((m) {
                return Chip(
                  label: Text('${_paymentIcon(m)}  $m',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                  backgroundColor: const Color(0xFF1E2E4E),
                  side: const BorderSide(color: Color(0xFF304060)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 3: More Information — Long-form text input ──────────────────────
  // ── ටැබ් 3: වැඩිදුර තොරතුරු — දිර්ඝ ආකාරයේ ආදානය ──────────────────────
  Widget _buildMoreInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'ℹ️  More Information',
            'Add extra details about the event — lineup, dress code, parking, etc.',
          ),
          const SizedBox(height: 20),
          _editorCard(
            children: [
              _label('Event Information'),
              const SizedBox(height: 8),
              _textField(
                controller: _moreInfoCtrl,
                hint:
                    'Add full event description, artist lineups, parking info, dress code, etc.',
                maxLines: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab 4: Booking Policy — Toggle between default and custom policy ────
  // ── ටැබ් 4: ප්‍රතිපත්තිය — default සහ custom policy අතර ටොගලය ────────────
  Widget _buildPolicyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            '📋  Booking Policy',
            'Use the comprehensive default policy or write your own custom policy.',
          ),
          const SizedBox(height: 20),
          _editorCard(
            children: [
              // Toggle row: Default policy vs Custom policy
              // ටොගල් රේඛාව: Default policy vs Custom policy
              Row(
                children: [
                  Expanded(
                    child: _toggleButton(
                      label: '📄  Use Default Policy',
                      selected: _useDefaultPolicy,
                      onTap: () =>
                          setState(() => _useDefaultPolicy = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _toggleButton(
                      label: '✏️  Write Custom Policy',
                      selected: !_useDefaultPolicy,
                      onTap: () =>
                          setState(() => _useDefaultPolicy = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Show info badge for default, or text field for custom
              // Default සඳහා info badge, custom සඳහා text field
              if (_useDefaultPolicy)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2010),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color:
                            AppColors.success.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.success, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The comprehensive 12-section default policy (Ticket Purchase, Payment, Refunds, Entry Policy, Security, Food & Beverages, Age Restrictions, Guest Conduct, Photography, Liability, eTicket Delivery, and Contact) will be shown on the ticket page.',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _label('Custom Booking Policy'),
                const SizedBox(height: 8),
                _textField(
                  controller: _bookingPolicyCtrl,
                  hint:
                      'Write your own booking policy here. You can include refund terms, entry rules, etc.',
                  maxLines: 12,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab 5: Organizer Details — About, phone, email with live preview ────
  // ── ටැබ් 5: සංවිධායක විස්තර — About, දූ, ඊමේල් සජීවී preview සමඟ ──────
  Widget _buildOrganizerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            '🏢  Organizer / Organization Details',
            "Fill in your organization's profile that will appear on the ticket page.",
          ),
          const SizedBox(height: 20),
          _editorCard(
            children: [
              _label('About Your Organization'),
              const SizedBox(height: 8),
              _textField(
                controller: _orgAboutCtrl,
                hint:
                    "e.g. Waters Edge is Sri Lanka's premier event venue known for world-class concerts and corporate events since 2003.",
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _label('Contact Phone / WhatsApp'),
              const SizedBox(height: 8),
              _textField(
                controller: _orgPhoneCtrl,
                hint: 'e.g. +94 727 600 700',
                maxLines: 1,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _label('Contact Email'),
              const SizedBox(height: 8),
              _textField(
                controller: _orgEmailCtrl,
                hint: 'e.g. support@mytickets.lk',
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Live preview card for organizer info
          // සංවිධායක info සජීවී preview card
          _previewCard(
            title: '🟢  Preview: Organizer Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.organizerAccent
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.organizerAccent, width: 1.5),
                      ),
                      child: const Icon(Icons.business_center_rounded,
                          color: AppColors.organizerAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Organizer name from event object (not editable here)
                          // event object හි සංවිධායකයාගේ නම (මෙහිදී සංස්කරණය කළ නොහැකිය)
                          Text(
                            widget.event.organizer.isNotEmpty
                                ? widget.event.organizer
                                : 'Your Organization',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Text(
                            '${widget.event.city}, Sri Lanka',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Reactive about text | ප්‍රතික්‍රියාශීලී about පෙළ
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _orgAboutCtrl,
                  builder: (_, v, __) => v.text.isEmpty
                      ? const SizedBox.shrink()
                      : Text(v.text,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.5)),
                ),
                const SizedBox(height: 10),
                // Reactive phone row | ප්‍රතික්‍රියාශීලී phone රේඛාව
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _orgPhoneCtrl,
                  builder: (_, v, __) => v.text.isEmpty
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 14,
                                color: AppColors.organizerAccent),
                            const SizedBox(width: 6),
                            Text(v.text,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                ),
                // Reactive email row | ප්‍රතික්‍රියාශීලී email රේඛාව
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _orgEmailCtrl,
                  builder: (_, v, __) => v.text.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.email_outlined,
                                  size: 14,
                                  color: AppColors.organizerAccent),
                              const SizedBox(width: 6),
                              Text(v.text,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared UI Helpers ───────────────────────────────────────────────────
  // ── පොදු UI helper ශ්‍රිත ────────────────────────────────────────────────

  // Section header with title and subtitle
  // Title සහ subtitle සහිත section header
  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4)),
      ],
    );
  }

  // Dark card container for grouped editor fields
  // Editor fields සඳහා group කළ dark card
  Widget _editorCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2E4E), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Preview card with a colored border and title
  // Colored border සහ title සහිත preview card
  Widget _previewCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF071830),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.organizerAccent.withValues(alpha: 0.3),
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: AppColors.organizerAccent.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // Small muted label above fields
  // Fields ඉහළ කුඩා muted label
  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3));
  }

  // Styled text field shared across all tabs
  // සියළු tabs හරහා share කළ styled text field
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: AppColors.organizerAccent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF030F26),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E2E4E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E2E4E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppColors.organizerAccent, width: 1.5),
        ),
      ),
    );
  }

  // Animated toggle button between two options (e.g. Default / Custom policy)
  // ජීව්‍රිත ටොගල් බොත්තම — options 2 අතර (e.g. Default / Custom)
  Widget _toggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.organizerAccent.withValues(alpha: 0.15)
              : const Color(0xFF030F26),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.organizerAccent
                : const Color(0xFF1E2E4E),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white38,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Maps payment method name to its emoji icon
  // ගෙවීම් ක්‍රම නාමය emoji icon ට map කරයි
  String _paymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'visa':
        return '💳';
      case 'mastercard':
        return '🔴';
      case 'koko':
        return '🟣';
      case 'payhere':
        return '💰';
      case 'bank transfer':
        return '🏦';
      case 'cash on door':
        return '💵';
      default:
        return '💳';
    }
  }
}
