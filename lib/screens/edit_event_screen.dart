// lib/screens/edit_event_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// EditEventScreen
// Allows an organizer to edit venue, date/time, and ticket type prices for an event.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../models/ticket_type.dart';
import '../services/firestore_service.dart';
import '../providers/organizer_provider.dart';
import '../theme/color_palette.dart';

class EditEventScreen extends StatefulWidget {
  static const routeName = '/edit_event';

  final Ticket event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  bool _isLoading = false;

  final FirestoreService _fs = FirestoreService();

  List<TicketType> _ticketTypes = [];
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _seatControllers = {};

  @override
  void initState() {
    super.initState();
    _venueController.text = widget.event.venue;
    _cityController.text = widget.event.city;
    _selectedDate = widget.event.eventDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.eventDate);
    if (widget.event.eventEndDate != null) {
      _selectedEndDate = widget.event.eventEndDate;
      _selectedEndTime = TimeOfDay.fromDateTime(widget.event.eventEndDate!);
    }
    _loadTicketTypes();
  }

  Future<void> _loadTicketTypes() async {
    setState(() => _isLoading = true);
    final types = await _fs.getTicketTypes(widget.event.id);
    for (final t in types) {
      _priceControllers[t.id] = TextEditingController(text: t.price.toString());
      _nameControllers[t.id] = TextEditingController(text: t.name);
      _seatControllers[t.id] =
          TextEditingController(text: t.totalQuantity.toString());
    }
    setState(() {
      _ticketTypes = types;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _venueController.dispose();
    _cityController.dispose();
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    for (final c in _seatControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedEndDate = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedEndTime = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final orgProvider = context.read<OrganizerProvider>();

      // Prepare event fields to update
      final DateTime newStart = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      DateTime? newEnd;
      if (_selectedEndDate != null && _selectedEndTime != null) {
        newEnd = DateTime(
          _selectedEndDate!.year,
          _selectedEndDate!.month,
          _selectedEndDate!.day,
          _selectedEndTime!.hour,
          _selectedEndTime!.minute,
        );
      }

      // Update ticket type fields (name, price, totalQuantity) and compute base price & seat aggregates
      double basePrice = double.infinity;
      int sumTotalSeats = 0;
      int sumAvailableSeats = 0;
      for (final type in _ticketTypes) {
        final priceCtrl = _priceControllers[type.id]!;
        final nameCtrl = _nameControllers[type.id]!;
        final seatCtrl = _seatControllers[type.id]!;

        final newPrice = double.tryParse(priceCtrl.text.trim()) ?? type.price;
        final newName = nameCtrl.text.trim();
        final newTotal =
            int.tryParse(seatCtrl.text.trim()) ?? type.totalQuantity;

        // Preserve already sold quantity by capping availableQuantity to newTotal when shrinking
        final int newAvailable = type.availableQuantity <= newTotal
            ? type.availableQuantity
            : newTotal;

        final Map<String, dynamic> updateTypeData = {
          'price': newPrice,
          'name': newName,
          'totalQuantity': newTotal,
          'availableQuantity': newAvailable,
        };

        await _fs.updateTicketType(widget.event.id, type.id, updateTypeData);

        if (newPrice < basePrice) {
          basePrice = newPrice;
        }
        sumTotalSeats += newTotal;
        sumAvailableSeats += newAvailable;
      }
      if (basePrice == double.infinity) {
        basePrice = widget.event.price;
      }

      final Map<String, dynamic> updateData = {
        'venue': _venueController.text.trim(),
        'city': _cityController.text.trim(),
        'eventDate': Timestamp.fromDate(newStart),
        'price': basePrice,
        'totalSeats': sumTotalSeats,
        'availableSeats': sumAvailableSeats,
      };
      if (newEnd != null) {
        updateData['eventEndDate'] = Timestamp.fromDate(newEnd);
      }

      final success =
          await orgProvider.updateEvent(widget.event.id, updateData);
      if (success) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Event updated successfully'),
          backgroundColor: AppColors.success,
        ));
        Navigator.of(context).pop(true);
      } else {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(orgProvider.error ?? 'Failed to update event'),
          backgroundColor: AppColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: AppColors.organizerAccent,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _venueController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Venue',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _cityController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Time',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text(_selectedTime.format(context),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Date (optional)',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text(
                            _selectedEndDate == null
                                ? 'Not set'
                                : '${_selectedEndDate!.day.toString().padLeft(2, '0')} ${_monthName(_selectedEndDate!.month)} ${_selectedEndDate!.year}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Time (optional)',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text(
                              _selectedEndTime == null
                                  ? 'Not set'
                                  : _selectedEndTime!.format(context),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Ticket Prices',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              for (final t in _ticketTypes)
                Card(
                  color: AppColors.cardColor,
                  margin: const EdgeInsets.only(bottom: 8, top: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameControllers[t.id],
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Type Name',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            controller: _priceControllers[t.id],
                            style: const TextStyle(color: Colors.white),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration:
                                const InputDecoration(labelText: 'Price'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 90,
                          child: TextFormField(
                            controller: _seatControllers[t.id],
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Seats'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(v.trim()) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.organizerAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
