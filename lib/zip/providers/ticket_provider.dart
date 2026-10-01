// lib/providers/ticket_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/ticket_type.dart';
import '../services/firestore_service.dart';

class TicketProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Ticket> _events = [];
  List<Ticket> _featured = [];
  List<Ticket> _filtered = [];
  List<TicketType> _currentEventTypes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String? _error;
  StreamSubscription? _eventsSub;
  StreamSubscription? _featuredSub;

  static const List<String> categories = [
    'All', 'Concert', 'Sports', 'Theater', 'Movie', 'Festival'
  ];

  List<Ticket> get events => _filtered.isNotEmpty || _searchQuery.isNotEmpty || _selectedCategory != 'All'
      ? _filtered
      : _events;
  List<Ticket> get allEvents => _events;
  List<Ticket> get featured => _featured;
  List<TicketType> get currentEventTypes => _currentEventTypes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String? get error => _error;

  TicketProvider() {
    _listenToEvents();
  }

  void _listenToEvents() {
    _isLoading = true;
    notifyListeners();

    _eventsSub = _service.streamPublishedEvents().listen(
      (events) {
        _events = events;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    _featuredSub = _service.streamFeaturedEvents().listen(
      (events) {
        _featured = events;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<Ticket>.from(_events);

    if (_selectedCategory != 'All') {
      result = result.where((e) => e.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) =>
          e.eventName.toLowerCase().contains(q) ||
          e.venue.toLowerCase().contains(q) ||
          e.organizer.toLowerCase().contains(q) ||
          e.city.toLowerCase().contains(q)).toList();
    }

    _filtered = result;
  }

  Future<void> loadTicketTypes(String eventId) async {
    try {
      _currentEventTypes = await _service.getTicketTypes(eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _eventsSub?.cancel();
    _featuredSub?.cancel();
    _listenToEvents();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _filtered = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _featuredSub?.cancel();
    super.dispose();
  }
}
