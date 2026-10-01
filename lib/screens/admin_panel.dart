// lib/screens/admin_panel.dart
// ─────────────────────────────────────────────────────────────────────────────
// AdminPanel | පරිපාලක පුවරුව (Admin Panel Screen)
// Direct event creation form accessible only by admin accounts.
// Creates a raw Ticket object and pushes it to Firestore via addTicket().
// Admin ගිණුම් හරහා පමණක් ප්‍රවේශ විය හැකි සිදුවීම් නිර්මාණ පෝරමය.
// Ticket වස්තුවක් ගොඩනා Firestore හි addTicket() හරහා සෙදෙයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../services/firestore_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  // ─── Form Key | පෝරම යතුර ─────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>(); // Used to validate before submit | ඉදිරිපත් කිරීමට පෙර සත්‍යාපනය

  // ─── Text Controllers | පාඨ ආදාන පාලක ────────────────────────────────────
  final _nameController = TextEditingController();       // Event name | සිදුවීමේ නම
  final _descController = TextEditingController();       // Description | විස්තරය
  final _imageController = TextEditingController();      // Image URL | රූප URL
  final _venueController = TextEditingController();      // Venue | ස්ථානය
  final _dateController = TextEditingController();       // Date string YYYY-MM-DD | දිනය
  final _priceController = TextEditingController();      // Ticket price | ප්‍රවේශ මිල
  final _categoryController = TextEditingController();   // Category | ප්‍රවර්ගය
  final _seatsController = TextEditingController();      // Available seats | ඉතිරි ආසන
  final _organizerController = TextEditingController();  // Organizer name | සංවිධායකයාගේ නම

  bool _isLoading = false; // Prevents double-submits | ද්විත්ව ඉදිරිපත් කිරීම් වළකිනය

  @override
  void dispose() {
    // Dispose all controllers to release memory | සියළු controllers ප්‍රකාශ නිදහස් කිරීම
    _nameController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _seatsController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  // ─── _submit: Build a Ticket and push to Firestore | Ticket ගොඩනා Firestore ට යවයි ──
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final firestore = context.read<FirestoreService>();

      // Build a Ticket object from form input fields
      // ආදාන ක්ෂේත්‍ර භාවිතා කර Ticket වස්තුවක් ගොඩනඟයි
      final ticket = Ticket(
        id: '',                                               // ID auto-assigned by Firestore | Firestore විසින් ස්වයංක්‍රීය ID
        eventName: _nameController.text.trim(),
        eventDescription: _descController.text.trim(),
        eventImage: _imageController.text.trim(),
        venue: _venueController.text.trim(),
        eventDate: DateTime.parse(_dateController.text.trim()), // Parse date string | දිනය parse කරයි
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        category: _categoryController.text.trim(),
        availableSeats: int.tryParse(_seatsController.text.trim()) ?? 0,
        organizer: _organizerController.text.trim(),
      );

      // Push event to Firestore and show confirmation snackbar
      // Firestore ට සිදුවීම ඉදිරිපත් කර සාර්ථකත්ව Snackbar පෙන්වයි
      final id = await firestore.addTicket(ticket);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Event uploaded: $id')));
        _formKey.currentState!.reset(); // Clear form after success | ජය ලැබීමෙන් පසු පෝරමය නිර්මල කරයි
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Event Name field | සිදුවීමේ නම ක්ෂේත්‍රය
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              // Description field (multi-line) | විස්තර ක්ෂේත්‍රය (බහු රේඛා)
              TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3),
              // Image URL field | රූප URL ක්ෂේත්‍රය
              TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: 'Image URL')),
              // Venue field | ස්ථාන ක්ෂේත්‍රය
              TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(labelText: 'Venue')),
              // Date field with YYYY-MM-DD format validation | YYYY-MM-DD ආකෘති සත්‍යාපනය සහිත දිනය
              TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                      labelText: 'Event Date (YYYY-MM-DD)'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    try {
                      DateTime.parse(v);
                      return null;
                    } catch (e) {
                      return 'Invalid date'; // Invalid format | වලංගු නොවන ආකෘතිය
                    }
                  }),
              // Price field | ප්‍රවේශ මිල ක්ෂේත්‍රය
              TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price')),
              // Category field | ප්‍රවර්ගය ක්ෂේත්‍රය
              TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category')),
              // Available Seats (numeric) | ඉතිරිව ඇති ආසන (සංඛ්‍යාත්මක)
              TextFormField(
                  controller: _seatsController,
                  decoration:
                      const InputDecoration(labelText: 'Available Seats'),
                  keyboardType: TextInputType.number),
              // Organizer name field | සංවිධායකයාගේ නම ක්ෂේත්‍රය
              TextFormField(
                  controller: _organizerController,
                  decoration: const InputDecoration(labelText: 'Organizer')),
              const SizedBox(height: 16),
              // Submit button — shows spinner while loading
              // ඉදිරිපත් කිරීමේ බොත්තම — Loading අතරතුර spinner පෙන්වයි
              ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Upload Event')),
            ],
          ),
        ),
      ),
    );
  }
}
