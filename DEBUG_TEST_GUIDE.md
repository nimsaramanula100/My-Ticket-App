# Debug Testing Guide - Event Creation Data Flow

This guide will help you test and verify that events are being properly created and persisted to Firebase Firestore.

## Prerequisites
- ✅ Debug logging has been added to all critical data flow points
- ✅ Flutter project compiles successfully
- ✅ Firebase project is configured and running
- ✅ You are authenticated in the app

## Step-by-Step Testing

### Phase 1: Start the App in Debug Mode

1. **Connect a device or emulator**
   ```bash
   flutter devices
   ```

2. **Launch the app with verbose logging**
   ```bash
   flutter run -v
   ```
   - Keep this terminal open to watch console output
   - Look for log messages starting with `[FIRESTORE]`, `[ORGANIZER]`, `[TICKET_PROVIDER]`

### Phase 2: Create a Test Event

1. **Navigate to "Create Event" screen**
   - Tap the **"+"** button or **"Create Event"** option
   
2. **Fill in the form with recognizable test data:**
   
   | Field | Test Value | Purpose |
   |-------|-----------|---------|
   | Event Name | `TEST_EVENT_2024` | Easy to find in Firestore |
   | Venue | `Test Venue` | Verify basic data |
   | City | `Test City` | Verify location capture |
   | Date | Tomorrow's date | Valid future date |
   | Time | 10:00 AM | Any valid time |
   | Main Category | `Music & Concerts` | Test category system |
   | Sub Category | `Pop Music` | Test subcategory system |
   | Description | `This is a test event` | Verify text fields |
   | Price | `500` | Test numeric field |
   | Total Tickets | `100` | Test quantity |

3. **Verify form validation shows no errors**, then **tap "Create Event"**

### Phase 3: Monitor Console Output

Watch the terminal/console for the following sequence of log messages:

#### Expected Log Sequence

```
[ORGANIZER] 🔍 createEvent called for: TEST_EVENT_2024
[ORGANIZER] 🎯 Event categories: [Music & Concerts, Pop Music]
[ORGANIZER] 👤 Organizer: [YOUR_USER_ID]
    ↓
[FIRESTORE] 📝 Saving event: TEST_EVENT_2024
[FIRESTORE] 🏷️  Category: 
[FIRESTORE] 📊 Categories array: [Music & Concerts, Pop Music]
[FIRESTORE] 👤 Organizer ID: [YOUR_USER_ID]
[FIRESTORE] 📋 Status: published
    ↓
[FIRESTORE] ✅ Event auto-saved with ID: [DOCUMENT_ID]
    ↓
[ORGANIZER] ✅ Ticket type added: General Admission
[ORGANIZER] 🎉 Event fully created!
```

**What each log tells you:**
- 🔍 Event data received by OrganizerProvider
- 🎯 Categories array structure confirmed
- 📝 Event data being sent to Firestore
- 📊 Categories array properly formatted
- ✅ Firestore accepted the write
- 🎉 Entire transaction successful

### Phase 4: Verify Data in Firebase Console

1. **Open Firebase Console** → https://console.firebase.google.com
2. **Select project: `mytickets-483fb`**
3. **Navigate to Firestore Database**
4. **Look for `events` collection**
5. **Find document with name matching `TEST_EVENT_2024`**

#### Check Document Structure

Expected document should contain:

```json
{
  "eventName": "TEST_EVENT_2024",
  "venue": "Test Venue",
  "city": "Test City",
  "category": "",
  "categories": ["Music & Concerts", "Pop Music"],
  "organizerId": "[YOUR_USER_ID]",
  "status": "published",
  "date": "2024-XX-XX",
  "time": "10:00 AM",
  "description": "This is a test event",
  "ticketTypes": [
    {
      "name": "General Admission",
      "price": 500,
      "totalQuantity": 100,
      "availableQuantity": 100
    }
  ]
}
```

### Phase 5: Verify Event Appears in App

1. **Go to Home Screen**
2. **Look for "TEST_EVENT_2024" in the event list**
3. **Check that the event displays with:**
   - Correct event name
   - Correct venue and city
   - Correct category icon (Music icon for Music & Concerts)
   - Correct category colors
   - Price showing as "Rs. 500"

### Phase 6: Test Category Filtering

1. **Filter by main category "Music & Concerts"**
   - `TEST_EVENT_2024` should appear
2. **Filter by subcategory "Pop Music"**
   - `TEST_EVENT_2024` should appear
3. **Filter by different category (e.g., "Sports")**
   - `TEST_EVENT_2024` should NOT appear

## Troubleshooting

### Issue: No console logs appear

**Solution:**
- Verify you're looking at the correct console (not system logs)
- Make sure you ran with `-v` flag: `flutter run -v`
- Check that you're logged in as organizer user
- Verify organizer ID is not empty

### Issue: Logs show but no "✅ Event saved" message

**Problem:** Write to Firestore failed
- Check Firebase Firestore rules are correct
- Verify organizer ID is valid
- Check that Firestore is initialized

**Solution:**
```
Check console for [FIRESTORE] ❌ ERROR message for details
```

### Issue: Event appears in Firebase but not in app

**Problem:** TicketProvider not streaming events
- Check for errors in `[TICKET_PROVIDER]` logs
- Verify event status is "published"
- Clear app cache and restart

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Event appears but with wrong category

**Problem:** Categories array structure incorrect
- Check that categories is an array `[mainCategory, subCategory]`
- NOT a string "mainCategory-subCategory"
- NOT two separate fields

**Solution:**
- Verify in Firebase Console that `categories` field is an array type
- If it's a string, the model's serialization is incorrect

## Next Steps After Successful Test

If the test is successful:
1. ✅ Category system is working
2. ✅ Event creation is working
3. ✅ Firestore persistence is working
4. ✅ Real-time streaming is working

Then proceed to:
- Create multiple events with different categories
- Test advanced category filtering
- Test search functionality
- Deploy to production

## Console Log Legend

| Symbol | Meaning | Action |
|--------|---------|--------|
| 📝 | Starting operation | Wait for result |
| ✅ | Success | Good! Continue |
| ❌ | Error/Failure | Check error message |
| 🔍 | Checking/Verifying | Wait for result |
| 📊 | Data/Status | Informational |
| 👤 | User/Auth related | Verify user ID matches |
| 🎯 | Target/Goal | Informational |
| ⭐ | Special/Featured | Informational |
| 📡 | Network/Stream | Waiting for data |
| ⏱️ | Timeout | May indicate slow network |
| 🎉 | Celebration/Done | Operation complete |

## Collecting Logs for Support

If you encounter issues, collect logs for support:

1. **Save console output:**
   ```bash
   flutter run -v > debug_logs.txt 2>&1
   ```

2. **Include:**
   - Full console output from `flutter run -v`
   - Screenshots of Firebase Console showing the event
   - Screenshots of app showing (or not showing) the event
   - Description of what you were trying to do

3. **Share with development team**

---

**Last Updated:** 2024
**Related Files:** DATABASE_DIAGNOSTICS.md, lib/services/firestore_service.dart, lib/providers/organizer_provider.dart, lib/providers/ticket_provider.dart
