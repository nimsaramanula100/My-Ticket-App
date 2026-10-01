# Database Diagnostics Guide

## Issue: Events not appearing in Firebase Firestore

This guide will help identify why events created in the app aren't appearing in your Firestore database.

---

## ✅ Quick Checks

### 1. **Verify Firestore Rules (Done ✓)**
- Your Firestore rules allow read/write until July 13, 2027
- Rules are NOT the issue

### 2. **Check Authentication Status**
When creating an event, verify these steps in the app:
1. ✓ User must be signed in (organizer)
2. ✓ Organizer must have an `organizerId` assigned
3. ✓ User role must be `UserRole.organizer`

### 3. **Enable Console Logging**
Add this to your `create_event_screen.dart` in the `_submit()` method to debug:

```dart
print('=== EVENT CREATION DEBUG ===');
print('User signed in: ${auth.isSignedIn}');
print('Organizer ID: ${auth.appUser?.organizerId}');
print('User role: ${auth.appUser?.role}');
print('Event name: ${_eventNameController.text}');
print('Category: $_selectedMainCategory');
print('Subcategory: $_selectedSubCategory');
print('Creating event with ID: $eventId');
print('===========================');
```

---

## 🔍 Common Issues & Solutions

### Issue 1: User is not authenticated
**Symptoms:**
- "Organizer information missing" error message
- No events saved

**Solution:**
```dart
// In _submit() method, verify:
if (!auth.isSignedIn) {
  print('❌ User not signed in!');
  // Navigate to login
  Navigator.of(context).pushNamed('/login');
  return;
}
```

### Issue 2: Organizer ID is missing
**Symptoms:**
- User is signed in but organizer ID is empty
- "Organizer information missing" error

**Solution:**
```dart
// Check AuthProvider - ensure organizerId is set during signup
// In your auth_provider.dart, when organizer signs up, save organizerId:
await _firestore.collection('users').doc(uid).update({
  'organizerId': organizerId, // Should NOT be empty
});
```

### Issue 3: Firestore not initialized
**Symptoms:**
- App crashes or hangs when trying to create events
- No console errors

**Solution:**
```dart
// Verify FirebaseFirestore is initialized in main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Issue 4: Data saved but not visible in Console
**Symptoms:**
- No errors appear in console
- No events in Firebase Console
- Events might be saved to wrong collection

**Solutions:**
1. **Check collection names** - Should be `events` (not `tickets` or `Event`)
2. **Check document structure** - Use Firebase Console to verify fields:
   ```
   events/ > {eventId}/ > {fields}
   - eventName (string)
   - venue (string)
   - category (string) 
   - categories (array) ← NEW
   - status (string) = "published"
   - organizerId (string)
   ```

3. **Verify data is being written** - Add to `firestore_service.dart`:
   ```dart
   Future<String> addEvent(Ticket event) async {
     print('📝 Saving event to Firestore...');
     print('Event data: ${event.toMap()}');
     
     if (event.id.isNotEmpty) {
       await _db.collection('events').doc(event.id).set(event.toMap());
       print('✅ Event saved with ID: ${event.id}');
       return event.id;
     }
     
     final doc = await _db.collection('events').add(event.toMap());
     print('✅ Event auto-saved with ID: ${doc.id}');
     return doc.id;
   }
   ```

---

## 🛠️ Testing Steps

### Step 1: Create Test Event
1. Open Organizer Dashboard
2. Click "Create New Event"
3. Fill ONLY these fields:
   - Event Name: "TEST_EVENT_123"
   - Description: "Testing"
   - Venue: "Test Venue"
   - City: Leave default
   - Date: Select any future date
   - Ticket Type: Leave default (General Access, 1000, 100)
4. Click "Publish"

### Step 2: Check for Errors
- Watch Android Studio logcat or VS Code Debug Console
- Look for any error messages
- Capture the output

### Step 3: Verify in Firebase
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project "mytickets-483fb"
3. Go to **Firestore Database** > **Collection: events**
4. Look for document with eventName "TEST_EVENT_123"

### Step 4: Check in App
1. Go back to Home Screen
2. Check if the test event appears
3. If not, the filtering logic might be the issue

---

## 📊 Document Structure Verification

Your saved events should look like this in Firestore:

```json
{
  "eventName": "Neon Mantra Concert",
  "eventDescription": "Electronic music festival",
  "category": "Concert",           // Subcategory
  "categories": [                  // NEW - Main + Sub
    "Music & Concerts",
    "Concert"
  ],
  "status": "published",           // IMPORTANT
  "organizerId": "org_12345",      // Must not be empty
  "venue": "Colombo Hilton",
  "city": "Colombo",
  "eventDate": Timestamp(2026-08-15 18:00:00),
  "price": 1000,
  "availableSeats": 100,
  "totalSeats": 100
}
```

---

## 🚨 If Still Not Working

**Please provide:**

1. **Firebase Console Screenshot:**
   - Go to Firestore Database > Data tab
   - Show if `events` collection exists
   - Show any documents in that collection

2. **Console Logs:**
   - Create a test event
   - Copy all console output
   - Paste in error report

3. **Error Messages:**
   - Any red errors after clicking "Publish"?
   - Take a screenshot

---

## Quick Debug Code

Add this to `organizer_provider.dart` in the `createEvent` method:

```dart
Future<String?> createEvent(Ticket event, List<TicketType> ticketTypes) async {
  try {
    print('🔍 createEvent called');
    print('Event ID: ${event.id}');
    print('Event Name: ${event.eventName}');
    print('Categories: ${event.categories}');
    print('Organizer ID: ${event.organizerId}');
    
    final id = await _service.addEvent(event);
    print('✅ Event created with ID: $id');
    
    for (final type in ticketTypes) {
      await _service.addTicketType(id, type);
      print('✅ Ticket type added: ${type.name}');
    }
    
    return id;
  } catch (e) {
    print('❌ ERROR in createEvent: $e');
    _error = e.toString();
    notifyListeners();
    return null;
  }
}
```

---

## Summary Checklist

- [ ] User is signed in as organizer
- [ ] Organizer ID is not empty
- [ ] Console shows "Event saved with ID: ..."
- [ ] Firestore Console shows events collection
- [ ] Event documents have `status: "published"`
- [ ] Event documents have `categories` array (NEW)
- [ ] Home screen has category filter chips
- [ ] Selected category matches event's categories array

**Once you follow these steps, let me know what you find!**
