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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _seatsController = TextEditingController();
  final _organizerController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final firestore = context.read<FirestoreService>();
      final ticket = Ticket(
        id: '',
        eventName: _nameController.text.trim(),
        eventDescription: _descController.text.trim(),
        eventImage: _imageController.text.trim(),
        venue: _venueController.text.trim(),
        eventDate: DateTime.parse(_dateController.text.trim()),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        category: _categoryController.text.trim(),
        availableSeats: int.tryParse(_seatsController.text.trim()) ?? 0,
        organizer: _organizerController.text.trim(),
      );

      final id = await firestore.addTicket(ticket);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Event uploaded: $id')));
        _formKey.currentState!.reset();
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
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3),
              TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: 'Image URL')),
              TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(labelText: 'Venue')),
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
                      return 'Invalid date';
                    }
                  }),
              TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price')),
              TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category')),
              TextFormField(
                  controller: _seatsController,
                  decoration:
                      const InputDecoration(labelText: 'Available Seats'),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: _organizerController,
                  decoration: const InputDecoration(labelText: 'Organizer')),
              const SizedBox(height: 16),
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
