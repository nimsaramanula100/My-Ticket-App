// lib/providers/ticket_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// TicketProvider | ප්‍රවේශපත්‍ර (සිදුවීම්) ප්‍රොවයිඩර්
// Manages public event listings, category filters, and search functions.
// පොදු සිදුවීම් ලැයිස්තුව, කාණ්ඩ පෙරහන් සහ සෙවුම් කාර්යයන් කළමනාකරණය කරයි.
// UI widgets can listen to this provider to rebuild when events or queries change.
// සිදුවීම් හෝ සෙවුම් වෙනස් වන විට UI widgets යාවත්කාලීන කිරීමට මෙම ප්‍රොවයිඩරය උපකාරී වේ.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/ticket_type.dart';
import '../services/firestore_service.dart';

class TicketProvider extends ChangeNotifier {
  // Service to run database requests | දත්ත සමුදාය මෙහෙයුම් සඳහා වන සේවා වස්තුව
  final FirestoreService _service = FirestoreService();

  // ─── Private State Variables | පුද්ගලික තත්ව විචල්‍යයන් ──────────────────────
  List<Ticket> _events = [];              // All published events | ප්‍රසිද්ධ කර ඇති සියලුම සිදුවීම්
  List<Ticket> _featured = [];            // Featured events list | විශේෂිත සිදුවීම් ලැයිස්තුව
  List<Ticket> _filtered = [];            // Filtered results list | පෙරන ලද ප්‍රතිඵල ලැයිස්තුව
  List<TicketType> _currentEventTypes = []; // Pricing tiers of active event | තෝරාගත් සිදුවීමේ මිල මට්ටම්
  bool _isLoading = false;                // Loading status indicator | දත්ත පූරණය වන තත්ව සලකුණ
  String _searchQuery = '';               // Search input query text | සෙවීම සඳහා ඇතුළත් කළ පෙළ
  Set<String> _selectedCategories = {'All'}; // Active category filter | සක්‍රීය කාණ්ඩ පෙරහන් සමූහය
  String? _error;                         // Error logging container | ඇතිවූ දෝෂ පිළිබඳ විස්තරය
  StreamSubscription? _eventsSub;         // Main events stream subscription | ප්‍රධාන සිදුවීම් සජීවී දායකත්වය
  StreamSubscription? _featuredSub;       // Featured events stream subscription | විශේෂිත සිදුවීම් සජීවී දායකත්වය

  // List of pre-defined categories | කලින් අර්ථ දක්වන ලද කාණ්ඩ ලැයිස්තුව
  static const List<String> categories = [
    'All', 'Concert', 'Sports', 'Theater', 'Movie', 'Festival'
  ];

  // ─── Public Getters | පොදු Getters ─────────────────────────────────────────
  // Returns filtered list if search or category is active, else returns all events
  // සෙවීමක් හෝ කාණ්ඩ පෙරීමක් සක්‍රීය නම් පෙරන ලද ලැයිස්තුවත්, නැතහොත් සියලුම සිදුවීම් ලබා දෙයි
  List<Ticket> get events => _filtered.isNotEmpty || _searchQuery.isNotEmpty || !_selectedCategories.contains('All')
      ? _filtered
      : _events;
      
  List<Ticket> get allEvents => _events;
  List<Ticket> get featured => _featured;
  List<TicketType> get currentEventTypes => _currentEventTypes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  Set<String> get selectedCategories => _selectedCategories;
  
  // Single active category helper | දැනට සක්‍රීය ප්‍රධාන කාණ්ඩය ලබා දෙන සහකාර Getter එක
  String get selectedCategory => _selectedCategories.contains('All')
      ? 'All'
      : _selectedCategories.first;
      
  String? get error => _error;

  // Constructor - starts streaming events immediately
  // Constructor - වහාම සිදුවීම් සජීවීව ලබා ගැනීම ආරම්භ කරයි
  TicketProvider() {
    _listenToEvents();
  }

  // ─── _listenToEvents: Subscribes to Firestore database updates ────────────────
  // Listens to published and featured events in real-time.
  // ප්‍රසිද්ධ කළ සහ විශේෂිත සිදුවීම් සජීවීව දත්ත සමුදායෙන් ලබා ගනී.
  void _listenToEvents() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Safety timeout - stops loading spinner after 8 seconds to prevent hanging
    // ආරක්‍ෂිත පියවරක් ලෙස, තත්පර 8කට පසු loading spinner එක නතර කරවයි (අන්තර්ජාලය බිඳවැටුණහොත්)
    Future.delayed(const Duration(seconds: 8), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });

    // Subscribe to published events stream | ප්‍රසිද්ධ කළ සිදුවීම් වලට සජීවීව සම්බන්ධ වීම
    _eventsSub = _service.streamPublishedEvents().listen(
      (events) {
        _events = events;
        _applyFilters(); // Re-apply current search/category rules | වත්මන් සෙවීම්/කාණ්ඩ රීති නැවත යොදයි
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    // Subscribe to featured events stream | විශේෂිත සිදුවීම් වලට සජීවීව සම්බන්ධ වීම
    _featuredSub = _service.streamFeaturedEvents().listen(
      (events) {
        _featured = events;
        notifyListeners();
      },
      onError: (_) {}, // Ignore featured stream errors silently | විශේෂිත සිදුවීම් වල දෝෂ නොසලකා හරියි
    );
  }

  // ─── setSearchQuery: Update search text | සෙවුම් පෙළ යාවත්කාලීන කිරීම ──────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ─── setCategory: Select category (Legacy) | කාණ්ඩය තේරීම ─────────────────────
  void setCategory(String category) {
    toggleCategory(category);
  }

  // ─── toggleCategory: Select or multi-select categories | කාණ්ඩය සක්‍රීය/අක්‍රීය කිරීම ──
  // Toggles the category selection and re-evaluates filters.
  // තෝරාගත් කාණ්ඩ පෙරහන් යාවත්කාලීන කර සිදුවීම් ලැයිස්තුව නැවත පෙරා ගනී.
  void toggleCategory(String category) {
    if (category == 'All') {
      _selectedCategories = {'All'};
    } else {
      _selectedCategories.remove('All');
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
        if (_selectedCategories.isEmpty) {
          _selectedCategories.add('All');
        }
      } else {
        _selectedCategories.add(category);
      }
    }
    _applyFilters();
    notifyListeners();
  }

  // ─── _applyFilters: Perform client-side filtering | දේශීයව දත්ත පෙරීම ───────────
  // Evaluates both category checks and search keywords on current events.
  // වත්මන් සිදුවීම් ලැයිස්තුව මත කාණ්ඩ සහ සෙවුම් වචන ගලපා පෙරීම සිදු කරයි.
  void _applyFilters() {
    var result = List<Ticket>.from(_events);

    // 1. Category filter logic | 1. කාණ්ඩ අනුව පෙරීමේ තර්කය
    if (!_selectedCategories.contains('All') && _selectedCategories.isNotEmpty) {
      result = result.where((e) {
        return e.categories.any((cat) => _selectedCategories.contains(cat)) ||
               _selectedCategories.contains(e.category);
      }).toList();
    }

    // 2. Search keyword logic (Match name, venue, organizer or city)
    // 2. සෙවුම් වචන තර්කය (නම, ස්ථානය, සංවිධායක හෝ නගරය ගැලපීම)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) =>
          e.eventName.toLowerCase().contains(q) ||
          e.venue.toLowerCase().contains(q) ||
          e.organizer.toLowerCase().contains(q) ||
          e.city.toLowerCase().contains(q)).toList();
    }

    _filtered = result; // Save filtered list | පෙරන ලද ලැයිස්තුව සුරැකීම
  }

  // ─── loadTicketTypes: Retrieve pricing tiers | ප්‍රවේශපත්‍ර මිල මට්ටම් ලබා ගැනීම ───
  // Fetches subcollection data from Firestore for chosen event.
  // තෝරාගත් සිදුවීමට අදාළ ප්‍රවේශපත්‍ර කාණ්ඩ Firestore වෙතින් ලබා ගනී.
  Future<void> loadTicketTypes(String eventId) async {
    try {
      _currentEventTypes = await _service.getTicketTypes(eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─── refresh: Force reload streams | දත්ත නැවත පූරණය කරවීම ──────────────────────
  Future<void> refresh() async {
    _eventsSub?.cancel();
    _featuredSub?.cancel();
    _listenToEvents();
  }

  // ─── clearFilters: Reset search & categories | පෙරහන් සියල්ල ඉවත් කිරීම ──────────
  void clearFilters() {
    _searchQuery = '';
    _selectedCategories = {'All'};
    _filtered = [];
    notifyListeners();
  }

  // ─── dispose: Clean stream listeners | සම්පත් නිදහස් කිරීම ────────────────────────
  @override
  void dispose() {
    _eventsSub?.cancel();
    _featuredSub?.cancel();
    super.dispose();
  }
}
