// lib/screens/map_picker_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// MapPickerScreen | සිතියම් තෝරාගැනීමේ තිරය (Google Maps Location Picker)
// Interactive Google Map centered on Sri Lanka for selecting event venues.
// සිදුවීම් ස්ථාන තෝරා ගැනීම සඳහා Sri Lanka කේන්ද්‍ර කරගත් අන්තර්ක්‍රියාකාරී Google Map.
// Users tap on the map to drop a pin, and reverse geocoding resolves the
// tapped coordinates into a venue/address and city name.
// පරිශීලකයින් map එක මත tap කර pin එකක් දමයි, reverse geocoding මඟින්
// tap කළ ඛණ්ඩාංක venue/ලිපිනයක් සහ නගර නමක් බවට පරිවර්තනය කරයි.
// Returns {venue, city, latitude, longitude} to the calling screen.
// Calling screen වෙත {venue, city, latitude, longitude} ආපසු යවයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/color_palette.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // ─── Google Maps controller reference | Google Maps controller යොමුව ────────
  GoogleMapController? _mapController;

  // ─── Selected pin position (null = no pin placed) ───────────────────────────
  // තෝරාගත් pin ස්ථානය (null = pin එකක් තබා නැත)
  LatLng? _selectedPosition;

  // ─── Resolved address fields from reverse geocoding ─────────────────────────
  // Reverse geocoding මඟින් ලබාගත් ලිපින ක්ෂේත්‍ර
  String _resolvedVenue = '';
  String _resolvedCity = '';
  bool _isGeocoding = false;

  // ─── Search controller | සෙවුම් පාලකය ─────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // ─── Map marker set (only one marker at a time) ─────────────────────────────
  // Map marker set (එක වරකට marker එකක් පමණි)
  final Set<Marker> _markers = {};

  // ─── Initial camera position: Center of Sri Lanka ───────────────────────────
  // ආරම්භක camera ස්ථානය: Sri Lanka මධ්‍යය
  static const LatLng _sriLankaCenter = LatLng(7.8731, 80.7718);
  static const double _initialZoom = 7.5;

  // ─── Popular Sri Lankan cities for quick navigation ─────────────────────────
  // ඉක්මන් navigation සඳහා ජනප්‍රිය Sri Lanka නගර
  static const List<Map<String, dynamic>> _quickCities = [
    {'name': 'Colombo', 'lat': 6.9271, 'lng': 79.8612},
    {'name': 'Kandy', 'lat': 7.2906, 'lng': 80.6337},
    {'name': 'Galle', 'lat': 6.0535, 'lng': 80.2210},
    {'name': 'Jaffna', 'lat': 9.6615, 'lng': 80.0255},
    {'name': 'Negombo', 'lat': 7.2083, 'lng': 79.8358},
    {'name': 'Nuwara Eliya', 'lat': 6.9497, 'lng': 80.7891},
    {'name': 'Matara', 'lat': 5.9549, 'lng': 80.5550},
    {'name': 'Trincomalee', 'lat': 8.5874, 'lng': 81.2152},
    {'name': 'Anuradhapura', 'lat': 8.3114, 'lng': 80.4037},
    {'name': 'Batticaloa', 'lat': 7.7170, 'lng': 81.6924},
  ];

  // ─── _onMapTap: Handle user tapping on the map ─────────────────────────────
  // _onMapTap: පරිශීලකයා map එක මත tap කළ විට handle කරයි
  // Places a marker at the tapped position and reverse geocodes the coordinates.
  // Tap කළ ස්ථානයේ marker එකක් තබා ඛණ්ඩාංක reverse geocode කරයි.
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _isGeocoding = true;
      // Clear previous marker and place a new one | පෙර marker ඉවත් කර අලුත් එකක් තබයි
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          // Custom info window showing coordinates | ඛණ්ඩාංක පෙන්වන info window
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet:
                '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    });
    // Perform reverse geocoding | Reverse geocoding සිදු කරයි
    _reverseGeocode(position);
  }

  // ─── _reverseGeocode: Convert lat/lng to a human-readable address ──────────
  // _reverseGeocode: lat/lng මිනිසුන්ට කියවිය හැකි ලිපිනයක් බවට පරිවර්තනය කරයි
  Future<void> _reverseGeocode(LatLng position) async {
    try {
      // Use the geocoding package's placemarkFromCoordinates function
      // geocoding package හි placemarkFromCoordinates function භාවිත කරයි
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        // Build a venue string from address components
        // ලිපින සංරචක වලින් venue string එකක් ගොඩනඟයි
        final venueParts = <String>[];
        if (place.name != null && place.name!.isNotEmpty) {
          venueParts.add(place.name!);
        }
        if (place.street != null &&
            place.street!.isNotEmpty &&
            place.street != place.name) {
          venueParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          venueParts.add(place.subLocality!);
        }

        // Determine the city name from locality or subAdministrativeArea
        // locality හෝ subAdministrativeArea වලින් නගර නම තීරණය කරයි
        final city = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            '';

        setState(() {
          _resolvedVenue =
              venueParts.isNotEmpty ? venueParts.join(', ') : 'Unknown venue';
          _resolvedCity = city;
          _isGeocoding = false;
          // Update marker info window with resolved address
          // Resolved ලිපිනය සමඟ marker info window යාවත්කාලීන කරයි
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('selected_location'),
              position: position,
              infoWindow: InfoWindow(
                title: _resolvedVenue,
                snippet: '$_resolvedCity, Sri Lanka',
              ),
            ),
          );
        });
      }
    } catch (e) {
      // Fallback if geocoding fails | Geocoding අසාර්ථක වුවහොත් fallback
      if (mounted) {
        setState(() {
          _resolvedVenue = 'Lat: ${position.latitude.toStringAsFixed(4)}';
          _resolvedCity = 'Lng: ${position.longitude.toStringAsFixed(4)}';
          _isGeocoding = false;
        });
      }
    }
  }

  // ─── _searchAddress: Search location by name ───────────────────────────────
  // _searchAddress: නමින් ස්ථානයක් සොයයි
  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isSearching = true;
    });

    try {
      // Append "Sri Lanka" to prioritize local results
      // දේශීය ප්‍රතිඵල වලට ප්‍රමුඛත්වය දීමට "Sri Lanka" එකතු කරයි
      final locations = await locationFromAddress('$query, Sri Lanka');
      if (locations.isNotEmpty && mounted) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        
        // Move camera to found location
        // සොයාගත් ස්ථානයට camera ගෙන යයි
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 14.0),
          ),
        );
        
        // Automatically drop a pin there
        // එහි ස්වයංක්‍රීයව pin එකක් තබයි
        _onMapTap(target);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not found. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // ─── _navigateToCity: Animate camera to a preset city ──────────────────────
  // _navigateToCity: Camera එක preset නගරයකට animate කරයි
  void _navigateToCity(Map<String, dynamic> city) {
    final target = LatLng(city['lat'] as double, city['lng'] as double);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 13.0),
      ),
    );
  }

  // ─── _confirmSelection: Return selected location data to the caller ────────
  // _confirmSelection: තෝරාගත් ස්ථාන දත්ත caller ට ආපසු යවයි
  // Returns same data structure {venue, city, latitude, longitude} expected
  // by CreateEventScreen's _pickLocationFromMap method.
  // CreateEventScreen හි _pickLocationFromMap method එක අපේක්ෂා කරන
  // {venue, city, latitude, longitude} data structure එකම ආපසු යවයි.
  void _confirmSelection() {
    if (_selectedPosition == null) return;
    Navigator.of(context).pop({
      'venue': _resolvedVenue,
      'city': _resolvedCity,
      'latitude': _selectedPosition!.latitude,
      'longitude': _selectedPosition!.longitude,
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── build: Renders the full Google Maps picker UI ─────────────────────────
  // build: සම්පූර්ණ Google Maps picker UI render කරයි
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ─── App Bar with title and confirm button ──────────────────────────────
      // ─── මාතෘකාව සහ තහවුරු බොත්තම සහිත App Bar ─────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.organizerAccent,
        title: const Text('Pick Event Location'),
        actions: [
          // Confirm button — active only after a pin has been placed
          // තහවුරු බොත්තම — pin එකක් තැබූ පසු පමණක් ක්‍රියාකාරී
          TextButton.icon(
            onPressed: _selectedPosition != null ? _confirmSelection : null,
            icon: Icon(Icons.check,
                color: _selectedPosition != null
                    ? Colors.white
                    : Colors.white38),
            label: Text('Confirm',
                style: TextStyle(
                    color: _selectedPosition != null
                        ? Colors.white
                        : Colors.white38)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Instruction banner | උපදෙස් banner ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.surface,
            child: const Row(
              children: [
                Icon(Icons.touch_app, color: AppColors.textMuted, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap on the map to select a venue location, then tap Confirm.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // ─── Search Bar | සෙවුම් තීරුව ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search for a venue or city...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: _searchAddress,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearching || _searchController.text.trim().isEmpty
                      ? null
                      : () => _searchAddress(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.organizerAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
          ),

          // ─── Quick city navigation chips | ඉක්මන් නගර navigation chips ─────
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: _quickCities.length,
              itemBuilder: (context, index) {
                final city = _quickCities[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(city['name'] as String,
                        style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.surface,
                    side:
                        const BorderSide(color: AppColors.surfaceVariant),
                    onPressed: () => _navigateToCity(city),
                  ),
                );
              },
            ),
          ),

          // ─── Google Map widget | Google Map විජට් ──────────────────────────
          Expanded(
            child: GoogleMap(
              // Initial camera centered on Sri Lanka | Sri Lanka කේන්ද්‍ර කරගත් ආරම්භක camera
              initialCameraPosition: const CameraPosition(
                target: _sriLankaCenter,
                zoom: _initialZoom,
              ),
              // Store the controller for later camera animations
              // පසුව camera animations සඳහා controller ගබඩා කරයි
              onMapCreated: (controller) => _mapController = controller,
              // Handle map taps to place markers | Markers තැබීමට map taps handle කරයි
              onTap: _onMapTap,
              // Display the selected marker | තෝරාගත් marker පෙන්වයි
              markers: _markers,
              // Enable zoom controls | Zoom controls සක්‍රිය කරයි
              zoomControlsEnabled: true,
              // Enable my location button (shows user's current position)
              // My location බොත්තම සක්‍රිය කරයි (පරිශීලකයාගේ වත්මන් ස්ථානය පෙන්වයි)
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              // Map type: normal street map | Map වර්ගය: සාමාන්‍ය street map
              mapType: MapType.normal,
              // Compass shown when map is rotated | Map භ්‍රමණය කළ විට compass පෙන්වයි
              compassEnabled: true,
            ),
          ),

          // ─── Selected location info panel | තෝරාගත් ස්ථාන තොරතුරු panel ────
          if (_selectedPosition != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.surfaceVariant, width: 1),
                ),
              ),
              child: _isGeocoding
                  // Show loading indicator while geocoding | Geocoding අතරතුර loading indicator පෙන්වයි
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.accent),
                        ),
                        SizedBox(width: 10),
                        Text('Resolving address...',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13)),
                      ],
                    )
                  // Show resolved venue/city info | Resolved venue/city තොරතුරු පෙන්වයි
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Venue/address name | Venue/ලිපින නම
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.organizerAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _resolvedVenue,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // City and country | නගරය සහ රට
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Text(
                            '$_resolvedCity, Sri Lanka',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Coordinates display | ඛණ්ඩාංක ප්‍රදර්ශනය
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Text(
                            'Lat: ${_selectedPosition!.latitude.toStringAsFixed(4)}, '
                            'Lng: ${_selectedPosition!.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
            ),

          // ─── Bottom confirm button | පහළ තහවුරු බොත්තම ─────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _selectedPosition != null ? _confirmSelection : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedPosition != null
                    ? AppColors.organizerAccent
                    : AppColors.surfaceVariant,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
