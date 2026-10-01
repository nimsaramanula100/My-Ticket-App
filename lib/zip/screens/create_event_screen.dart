// lib/screens/create_event_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/organizer_provider.dart';
import '../models/ticket.dart';
import '../theme/color_palette.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  String _selectedCategory = 'Concert';
  EventStatus _selectedStatus = EventStatus.published;
  bool _isLoading = false;

  static const List<String> _categories = [
    'Concert', 'Sports', 'Theater', 'Movie', 'Festival', 'Other'
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.organizerAccent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.organizerAccent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final orgProvider = context.read<OrganizerProvider>();

      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final organizerName =
          orgProvider.organizer?.name ?? auth.appUser?.name ?? 'Organizer';
      final organizerId = auth.appUser?.organizerId ?? '';

      final newEvent = Ticket(
        id: '',
        eventName: _eventNameController.text.trim(),
        eventDescription: _descriptionController.text.trim(),
        eventImage: _imageUrlController.text.trim(),
        venue: _venueController.text.trim(),
        eventDate: eventDateTime,
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        category: _selectedCategory,
        availableSeats:
            int.tryParse(_seatsController.text.trim()) ?? 0,
        totalSeats: int.tryParse(_seatsController.text.trim()) ?? 0,
        organizer: organizerName,
        organizerId: organizerId,
        status: _selectedStatus,
        city: _cityController.text.trim().isEmpty
            ? 'Colombo'
            : _cityController.text.trim(),
      );

      final createdId = await orgProvider.createEvent(newEvent);

      if (!mounted) return;
      if (createdId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orgProvider.error ?? 'Failed to create event'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.organizerAccent,
        title: const Text('Create New Event'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Publish',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section: Basic Info
            const _SectionHeader(label: 'Event Details'),
            const SizedBox(height: 12),

            // Event Name
            TextFormField(
              controller: _eventNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Event Name *',
                prefixIcon: Icon(Icons.event),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Event Description *',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Category Picker
            const _SectionHeader(label: 'Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.organizerAccent
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected
                            ? AppColors.organizerAccent
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Section: Location
            const _SectionHeader(label: 'Location'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _venueController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Venue Name *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _cityController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'City (default: Colombo)',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Section: Date & Time
            const _SectionHeader(label: 'Date & Time'),
            const SizedBox(height: 12),

            Row(
              children: [
                // Date picker button
                Expanded(
                  child: _DateTimeTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value:
                        '${_selectedDate.day.toString().padLeft(2, '0')} '
                        '${_monthName(_selectedDate.month)} '
                        '${_selectedDate.year}',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                // Time picker button
                Expanded(
                  child: _DateTimeTile(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: _selectedTime.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section: Ticketing
            const _SectionHeader(label: 'Ticketing'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price (Rs.) *',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      if (double.tryParse(val.trim()) == null) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _seatsController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available Seats *',
                      prefixIcon: Icon(Icons.event_seat_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      if (int.tryParse(val.trim()) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section: Media
            const _SectionHeader(label: 'Event Image (optional)'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Image URL',
                prefixIcon: Icon(Icons.image_outlined),
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 20),

            // Section: Status
            const _SectionHeader(label: 'Publication Status'),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusChip(
                  label: 'Publish Now',
                  icon: Icons.publish,
                  selected: _selectedStatus == EventStatus.published,
                  color: AppColors.success,
                  onTap: () =>
                      setState(() => _selectedStatus = EventStatus.published),
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  label: 'Save as Draft',
                  icon: Icons.drafts_outlined,
                  selected: _selectedStatus == EventStatus.draft,
                  color: AppColors.warning,
                  onTap: () =>
                      setState(() => _selectedStatus = EventStatus.draft),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: const Icon(Icons.event_available),
              label: Text(
                _selectedStatus == EventStatus.published
                    ? 'Create & Publish Event'
                    : 'Save as Draft',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.organizerAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

// ─── Section Header ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            height: 16,
            width: 3,
            decoration: BoxDecoration(
              color: AppColors.organizerAccent,
              borderRadius: BorderRadius.circular(2),
            )),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
      ],
    );
  }
}

// ─── Date/Time Tile ──────────────────────────────────────────────────────────
class _DateTimeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF243B55), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.organizerAccent),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : const Color(0xFF243B55),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? color : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    color: selected ? color : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
