# MyTickets - Flutter Ticket Booking App

A mobile ticket booking application built with Flutter and Firebase, similar to mytickets.lk. This app allows users to browse events, book tickets, and manage their reservations.

## Features

- **User Authentication**: Sign up and login with email/password using Firebase Auth
- **Event Browsing**: Browse events by category (Concert, Movie, Sports, Theater)
- **Ticket Details**: View detailed information about events including date, location, and pricing
- **Booking System**: Book tickets with quantity selection
- **Booking History**: View all past and current bookings
- **Real-time Updates**: Real-time data sync using Firebase Firestore
- **User Profiles**: Manage user information and settings
- **Category Filtering**: Filter events by category
- **Search**: Search for events by name

## Tech Stack

- **Frontend**: Flutter & Dart
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore (Database)
  - Firebase Storage
- **State Management**: Provider
- **Additional Libraries**: 
  - intl (Internationalization)
  - shared_preferences (Local Storage)
  - http (HTTP Requests)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── ticket_detail_screen.dart
├── models/                   # Data models
│   ├── ticket.dart
│   ├── booking.dart
│   └── user.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   └── firestore_service.dart
├── widgets/                  # Reusable widgets
│   └── ticket_card.dart
└── utils/                    # Utility functions
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio or Xcode (for emulator/device testing)
- A Firebase project account

### Installation

1. **Clone the repository** (or navigate to the project folder):
   ```bash
   cd flutterProject
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or select existing one
   - Add Android and iOS apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Update Firebase Options**:
   - Update `lib/firebase_options.dart` with your Firebase project credentials

### Securing Firebase credentials

- Avoid committing credentials like API keys and `google-services.json` to source control.
- Preferred: generate `lib/firebase_options.dart` using the FlutterFire CLI and keep it out of git, or pass credentials at build/run time with `--dart-define`.

Example (run on a development device):

```bash
flutter run \
   --dart-define=FIREBASE_API_KEY=your_api_key \
   --dart-define=FIREBASE_APP_ID=your_app_id \
   --dart-define=FIREBASE_PROJECT_ID=your_project_id \
   --dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket \
   --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
```

Or use the FlutterFire CLI to generate a `firebase_options.dart` file:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project your_project_id
```

After generating, ensure `lib/firebase_options.dart` and platform config files are not committed, or rotate keys if they were committed previously.

5. **Run the app**:
   ```bash
   flutter run
   ```

### Running on Different Platforms

**Android**:
```bash
flutter run -d android
```

**iOS**:
```bash
flutter run -d ios
```

**Web** (if enabled):
```bash
flutter run -d chrome
```

## Firebase Setup

### Enable Services

1. **Firebase Authentication**:
   - Enable Email/Password authentication
   - Go to Authentication → Sign-in method → Enable Email/Password

2. **Cloud Firestore**:
   - Create database in test mode (for development)
   - Set up collections: `users`, `tickets`, `bookings`

3. **Firebase Storage** (optional):
   - Enable for storing event images

### Firestore Collections

**tickets** - Event tickets
```
{
  eventName: string,
  eventDescription: string,
  eventImage: string (URL),
  venue: string,
  eventDate: timestamp,
  price: string,
  category: string,
  availableSeats: number,
  organizer: string
}
```

**bookings** - User bookings
```
{
  userId: string,
  ticketId: string,
  eventName: string,
  bookingDate: timestamp,
  quantity: number,
  totalPrice: double,
  status: string (pending/confirmed/cancelled),
  paymentMethod: string
}
```

**users** - User profiles
```
{
  name: string,
  email: string,
  phone: string,
  profileImage: string (URL),
  createdAt: timestamp
}
```

## Development

### Testing

Run tests:
```bash
flutter test
```

### Build Release

**Android APK**:
```bash
flutter build apk --release
```

**Android App Bundle**:
```bash
flutter build appbundle --release
```

**iOS**:
```bash
flutter build ios --release
```

## API Integration

The app uses REST APIs for some services. To add additional APIs:

1. Create a new service in `lib/services/`
2. Use the `http` package for HTTP requests
3. Implement error handling and data parsing

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add some feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit a pull request

## Troubleshooting

### Firebase Connection Issues
- Verify Firebase credentials in `firebase_options.dart`
- Ensure Firestore rules allow read/write operations
- Check internet connectivity

### Build Errors
- Run `flutter clean` and then `flutter pub get`
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Check Java version for Android builds

### Emulator Issues
- Kill and restart emulator
- Clear app cache: `flutter clean`

## Future Enhancements

- [ ] Payment integration (Razorpay, Stripe)
- [ ] Ticket QR code generation
- [ ] Email notifications
- [ ] Push notifications
- [ ] Admin dashboard
- [ ] Wishlist/Favorites functionality
- [ ] Review and rating system
- [ ] Multi-language support

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues or questions, please open an issue on the GitHub repository.

---

**Made with ❤️ using Flutter**
