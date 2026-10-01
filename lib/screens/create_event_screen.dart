// lib/screens/create_event_screen.dart
// CreateEventScreen - Allows event organizers to create and publish a new event or save it as a draft.
// Includes details like name, description, category, venue, map picker, date/time,
// customizable multiple ticket types/phases, deals/promos, payment methods,
// custom booking policies, and organizer bio/contact info.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/organizer_provider.dart';
import '../models/ticket.dart';
import '../models/ticket_type.dart';
import '../services/storage_service.dart';
import '../theme/color_palette.dart';
import '../utils/category_data.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // Form key for validating all form fields
  final _formKey = GlobalKey<FormState>();

  // Text Controllers for input fields
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _organizerAboutController = TextEditingController();
  final _organizerPhoneController = TextEditingController();
  final _organizerEmailController = TextEditingController();
  final _dealTitleController = TextEditingController();
  final _dealDescController = TextEditingController();
  final _moreInfoController = TextEditingController();
  final _customPolicyController = TextEditingController();

  // Start Date & Time defaults (default to 7 days in future)
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  // Optional End Date & Time
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  // Selected main and subcategory values for the event
  String _selectedMainCategory = CategoryData.mainCategories.first;
  String _selectedSubcategory =
      CategoryData.getSubcategories(CategoryData.mainCategories.first).first;

  List<String> get _subcategories =>
      CategoryData.getSubcategories(_selectedMainCategory);

  // Selected currency for ticket pricing
  String _selectedCurrency = Ticket.defaultCurrency;
  static const List<String> _currencyOptions = [Ticket.defaultCurrency, 'USD'];

  // Selected payment methods for checkout
  final List<String> _selectedPaymentMethods = ['Visa', 'Mastercard', 'Koko'];

  // Policy configuration state
  bool _useDefaultPolicy = true;

  // Publication status (default Published)
  EventStatus _selectedStatus = EventStatus.published;

  // Form submitting / image uploading loader flag
  bool _isLoading = false;

  // Map Coordinates
  double? _latitude;
  double? _longitude;

  // Local file path for chosen flyer banner image
  String? _pickedImagePath;

  // Multiple Ticket Types / Phases State List
  final List<Map<String, dynamic>> _ticketTypes = [
    {
      'nameController': TextEditingController(text: 'General Access'),
      'priceController': TextEditingController(text: '1000'),
      'seatsController': TextEditingController(text: '100'),
    }
  ];

  // ─── dispose: Clear text controllers to avoid leaks ─────────────────────
  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _cityController.dispose();
    _imageUrlController.dispose();
    _organizerAboutController.dispose();
    _organizerPhoneController.dispose();
    _organizerEmailController.dispose();
    _dealTitleController.dispose();
    _dealDescController.dispose();
    _moreInfoController.dispose();
    _customPolicyController.dispose();
    for (final type in _ticketTypes) {
      (type['nameController'] as TextEditingController).dispose();
      (type['priceController'] as TextEditingController).dispose();
      (type['seatsController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  // ─── _pickDate: Opens date picker for starting date ───────────────────────
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Reset end date if it is before start date
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
        }
      });
    }
  }

  // ─── _pickTime: Opens time picker for starting time ───────────────────────
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
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // ─── _pickEndDate: Opens date picker for optional end date ─────────────────
  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedDate,
      firstDate: _selectedDate,
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
    if (picked != null) {
      setState(() => _selectedEndDate = picked);
    }
  }

  // ─── _pickEndTime: Opens time picker for optional end time ─────────────────
  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedTime,
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
    if (picked != null) {
      setState(() => _selectedEndTime = picked);
    }
  }

  // ─── _pickLocationFromMap: Opens Google Maps MapPickerScreen ─────────────────
  // Pre-fills venue, city, latitude, and longitude on return.
  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.of(context).pushNamed('/map_picker')
        as Map<String, dynamic>?;
    if (result != null) {
      setState(() {
        _venueController.text = result['venue'] ?? '';
        _cityController.text = result['city'] ?? '';
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  // ─── _addTicketType: Appends a new ticket tier map to the ticketTypes list ──
  void _addTicketType() {
    setState(() {
      _ticketTypes.add({
        'nameController': TextEditingController(text: 'VIP'),
        'priceController': TextEditingController(text: '2000'),
        'seatsController': TextEditingController(text: '50'),
      });
    });
  }

  // ─── _removeTicketType: Disposes and deletes ticket type at the given index ─
  void _removeTicketType(int index) {
    if (_ticketTypes.length > 1) {
      setState(() {
        final item = _ticketTypes.removeAt(index);
        (item['nameController'] as TextEditingController).dispose();
        (item['priceController'] as TextEditingController).dispose();
        (item['seatsController'] as TextEditingController).dispose();
      });
    }
  }

  // ─── _submit: Validates inputs, uploads image, calculates base price, updates DB
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validation check | Validation check
    }

    // Additional required field checks | අමතර අනිවාර්ය ක්ෂේත්‍ර පරීක්ෂා කිරීම්
    if (_selectedMainCategory.isEmpty || _selectedSubcategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a main category and subcategory'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    // Validate organizer email and phone
    // සංවිධායක විද්‍යුත් තැපෑල සහ දුරකථනය validate කරයි
    if (_organizerEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your email is required'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (_organizerPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your phone number is required'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    // Check if the current user has a valid organizer ID
    // දැනට ලොග් වී සිටින පරිශීලකයාට organizer ID එකක් තිබේදැයි බලයි
    if ((context.read<AuthProvider>().appUser?.organizerId ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Organizer information missing'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final orgProvider = context.read<OrganizerProvider>();

      // Generate a unique Event ID beforehand so we can use it for subcollection writing
      final eventId = FirebaseFirestore.instance.collection('events').doc().id;

      // Handle Image Selection (upload if local path present, otherwise manual text field)
      String finalImageUrl = _imageUrlController.text.trim();
      if (_pickedImagePath != null) {
        final File file = File(_pickedImagePath!);
        finalImageUrl = await StorageService().uploadEventBanner(file, eventId);
      }

      // Start Date & Time combination
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // End Date & Time (optional event duration)
      DateTime? eventEndDateTime;
      if (_selectedEndDate != null && _selectedEndTime != null) {
        eventEndDateTime = DateTime(
          _selectedEndDate!.year,
          _selectedEndDate!.month,
          _selectedEndDate!.day,
          _selectedEndTime!.hour,
          _selectedEndTime!.minute,
        );
      }

      // Calculate aggregated metrics from custom ticket types
      double basePrice = double.infinity;
      int totalSeats = 0;
      final List<TicketType> parsedTicketTypes = [];

      for (final typeData in _ticketTypes) {
        final String name =
            (typeData['nameController'] as TextEditingController).text.trim();
        final double price = double.tryParse(
                (typeData['priceController'] as TextEditingController)
                    .text
                    .trim()) ??
            0.0;
        final int quantity = int.tryParse(
                (typeData['seatsController'] as TextEditingController)
                    .text
                    .trim()) ??
            0;

        // Base price is the lowest price tier among all ticket types
        if (price < basePrice) {
          basePrice = price;
        }
        totalSeats += quantity;

        parsedTicketTypes.add(
          TicketType(
            id: '', // Generated by Firestore inside createEvent
            eventId: eventId,
            name: name,
            price: price,
            totalQuantity: quantity,
            availableQuantity: quantity,
          ),
        );
      }

      if (basePrice == double.infinity) {
        basePrice = 0;
      }

      final organizerName =
          orgProvider.organizer?.name ?? auth.appUser?.name ?? 'Organizer';
      final organizerId = auth.appUser?.organizerId ?? '';

      // Build the Ticket event object | Ticket event object එක ගොඩනඟයි
      final newEvent = Ticket(
        id: eventId,
        eventName: _eventNameController.text.trim(),
        eventDescription: _descriptionController.text.trim(),
        eventImage: finalImageUrl,
        venue: _venueController.text.trim(),
        eventDate: eventDateTime,
        eventEndDate: eventEndDateTime,
        price: basePrice,
        currency: _selectedCurrency,
        category: _selectedSubcategory,
        categories: [_selectedMainCategory, _selectedSubcategory],
        availableSeats: totalSeats,
        totalSeats: totalSeats,
        organizer: organizerName,
        organizerId: organizerId,
        status: _selectedStatus,
        city: _cityController.text.trim().isEmpty
            ? 'Colombo'
            : _cityController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        dealTitle: _dealTitleController.text.trim(),
        dealDescription: _dealDescController.text.trim(),
        paymentMethods: _selectedPaymentMethods,
        organizerAbout: _organizerAboutController.text.trim(),
        organizerPhone: _organizerPhoneController.text.trim(),
        organizerEmail: _organizerEmailController.text.trim(),
        customBookingPolicy:
            _useDefaultPolicy ? '' : _customPolicyController.text.trim(),
        moreInformation: _moreInfoController.text.trim().isEmpty
            ? _descriptionController.text.trim()
            : _moreInfoController.text.trim(),
      );

      // Call OrganizerProvider to create the event and tickets in transaction
      // Event එක සහ tickets transaction එකකින් සෑදීමට OrganizerProvider අමතයි
      final createdId =
          await orgProvider.createEvent(newEvent, parsedTicketTypes);

      if (!mounted) return;
      if (createdId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event and Ticket Types published successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context)
            .pop(); // Back to dashboard | Dashboard එකට ආපසු යයි
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orgProvider.error ?? 'Failed to create event'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'), // English
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── build: Renders the Form screen interface ──────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.organizerAccent,
        title: const Text('Create New Event'),
        actions: [
          // Show spinner if submitting, otherwise show publish button
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

            // Event Name Input Field
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

            // Description Input Field
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

            // Category Picker Section
            const _SectionHeader(label: 'Category'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMainCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Main Category *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: CategoryData.mainCategories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedMainCategory = value;
                        final options = CategoryData.getSubcategories(value);
                        _selectedSubcategory =
                            options.isNotEmpty ? options.first : 'Other';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSubcategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Subcategory *',
                      prefixIcon: Icon(Icons.subdirectory_arrow_right),
                    ),
                    items: _subcategories
                        .map((subcat) => DropdownMenuItem(
                              value: subcat,
                              child: Text(
                                subcat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedSubcategory = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section: Location Details
            const _SectionHeader(label: 'Location'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _venueController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Venue Name *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton.filled(
                    onPressed: _pickLocationFromMap,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.organizerAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.map, color: Colors.white),
                    tooltip: 'Pick location on Map',
                  ),
                )
              ],
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
            if (_latitude != null && _longitude != null) ...[
              const SizedBox(height: 8),
              Text(
                'Coordinates: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),

            // Section: Date & Time / Duration Selection
            const _SectionHeader(label: 'Date & Time'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _DateTimeTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Start Date *',
                    value: '${_selectedDate.day.toString().padLeft(2, '0')} '
                        '${_monthName(_selectedDate.month)} '
                        '${_selectedDate.year}',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTimeTile(
                    icon: Icons.access_time_outlined,
                    label: 'Start Time *',
                    value: _selectedTime.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // End Date & End Time (Duration)
            Row(
              children: [
                Expanded(
                  child: _DateTimeTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'End Date (Optional)',
                    value: _selectedEndDate == null
                        ? 'Not set'
                        : '${_selectedEndDate!.day.toString().padLeft(2, '0')} '
                            '${_monthName(_selectedEndDate!.month)} '
                            '${_selectedEndDate!.year}',
                    onTap: _pickEndDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTimeTile(
                    icon: Icons.access_time_outlined,
                    label: 'End Time (Optional)',
                    value: _selectedEndTime == null
                        ? 'Not set'
                        : _selectedEndTime!.format(context),
                    onTap: _pickEndTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section: Ticket Types / Phases List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionHeader(label: 'Ticket Types / Phases'),
                TextButton.icon(
                  onPressed: _addTicketType,
                  icon: const Icon(Icons.add, color: AppColors.organizerAccent),
                  label: const Text('Add Type',
                      style: TextStyle(
                          color: AppColors.organizerAccent,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency *',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    items: _currencyOptions
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedCurrency = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ticketTypes.length,
              itemBuilder: (context, index) {
                final type = _ticketTypes[index];
                return Card(
                  color: AppColors.cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                        color: AppColors.surfaceVariant, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: type['nameController']
                                    as TextEditingController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Ticket Type Name (e.g. VIP) *',
                                  prefixIcon: Icon(Icons.label_outline),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            if (_ticketTypes.length > 1)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeTicketType(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: type['priceController']
                                    as TextEditingController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Price *',
                                  prefixText: '$_selectedCurrency ',
                                ),
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: type['seatsController']
                                    as TextEditingController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity / Seats *',
                                  prefixIcon: Icon(Icons.event_seat_outlined),
                                ),
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
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Organizer Customization & Ticket Page Features Section ────────
            // ── Premium Ticket Page Customization
            const _SectionHeader(label: 'Premium Ticket Page Customization'),
            const SizedBox(height: 12),

            // Card for Deals
            Card(
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    const BorderSide(color: AppColors.surfaceVariant, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🏷️  Available Deals',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dealTitleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Deal/Promo Title',
                        hintText:
                            'e.g. NEON MANTRA 25% OFF - Exclusive Promo Code',
                        prefixIcon: Icon(Icons.local_offer_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dealDescController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Deal Description',
                        hintText:
                            'e.g. Applicable deals will automatically take effect...',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Card for Payment Methods Details
            Card(
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    const BorderSide(color: AppColors.surfaceVariant, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💳  Available Payment Methods',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Visa',
                        'Mastercard',
                        'Koko',
                        'PayHere',
                        'Bank Transfer'
                      ].map((method) {
                        final isSelected =
                            _selectedPaymentMethods.contains(method);
                        return FilterChip(
                          label: Text(method),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedPaymentMethods.add(method);
                              } else {
                                if (_selectedPaymentMethods.length > 1) {
                                  _selectedPaymentMethods.remove(method);
                                }
                              }
                            });
                          },
                          selectedColor:
                              AppColors.organizerAccent.withValues(alpha: 0.3),
                          checkmarkColor: AppColors.organizerAccent,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: AppColors.surfaceVariant,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Card for More Info & Custom Booking Policy Details
            Card(
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    const BorderSide(color: AppColors.surfaceVariant, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ℹ️  More Event Information',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _moreInfoController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Lineup, dress code, extra details...',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.text_snippet_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('📋  Booking Policy',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Use Standard Policy'),
                            selected: _useDefaultPolicy,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _useDefaultPolicy = true);
                              }
                            },
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Write Custom Policy'),
                            selected: !_useDefaultPolicy,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _useDefaultPolicy = false);
                              }
                            },
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    if (!_useDefaultPolicy) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _customPolicyController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Custom Booking Policy',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.gavel_outlined),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Card for Organizer Bio/Contact Details
            Card(
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    const BorderSide(color: AppColors.surfaceVariant, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🏢  Organizer Details',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _organizerAboutController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'About Host / Organization',
                        prefixIcon: Icon(Icons.business_center_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _organizerPhoneController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone / WhatsApp',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _organizerEmailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section: Status of Publication
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

            // Submit / Publish button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: const Icon(Icons.event_available),
              label: Text(
                _selectedStatus == EventStatus.published
                    ? 'Create & Publish Event'
                    : 'Save as Draft',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // ─── _monthName: Converts integer month to 3-letter English short name ─────
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
}

// ─── Section Header Widget | Section Header Widget ───────────────────────────
// Renders a category/section label with an accent colored vertical bar marker
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

// ─── Date/Time Tile Widget | දිනය/වේලාව පෙන්වන Tile Widget ───────────────────
// A stylized clickable container displaying date or time details
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

// ─── Status Chip Widget | ප්‍රකාශන තත්ත්වය පෙන්වන Chip Widget ────────────────
// A choice chip for selecting 'Publish Now' or 'Save as Draft' status
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
              Icon(icon,
                  size: 16, color: selected ? color : AppColors.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: selected ? color : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
