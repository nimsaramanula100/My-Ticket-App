// lib/main.dart
// ─────────────────────────────────────────────────────────────────────────────
// App Entry Point | App ආරම්භ ස්ථානය
// This is the first file Flutter runs when the app starts.
// App ආරම්භ වූ විට Flutter ධාවනය කරන පළමු ගොනුව.
// It initializes Firebase, sets up state management providers,
// and defines all named routes for navigation.
// Firebase initialize කිරීම, state management providers setup කිරීම,
// සහ navigation සඳහා named routes නිර්වචනය කිරීම.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ticket_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/organizer_dashboard.dart';
import 'screens/create_event_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/admin_users_screen.dart';
import 'screens/map_picker_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'providers/auth_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/organizer_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

// ─── main(): App starting point | App ආරම්භ ශ්‍රිතය ────────────────────────
// The 'async' keyword is needed because Firebase initialization is async.
// Firebase initialization async ක්‍රියාවලියක් නිසා 'async' keyword අවශ්‍ය.
void main() async {
  // Ensures Flutter's binding is initialized before calling async ops
  // Async operations call කිරීමට පෙර Flutter binding initialize වී ඇත්දැයි සහතික කරයි
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with platform-specific options (from firebase_options.dart)
    // Platform-specific options (firebase_options.dart) සමඟ Firebase initialize කරයි
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Firebase App Check: protects backend resources from abuse (only in Release/Production)
    // Firebase App Check: backend resources abuse වලින් ආරක්ෂා කරයි (Release/Production mode හිදී)
    // In debug mode, App Check can block all Firebase requests without a registered debug token.
    // Debug mode හිදී, registered debug token නොමැතිව App Check Firebase requests block කළ හැකිය.
    if (!kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    }
  } catch (e) {
    // Log Firebase init errors but continue (app will still load without Firebase)
    // Firebase init errors log කරයි නමුත් ඉදිරියට යයි (Firebase නොමැතිව app load වේ)
    debugPrint("Firebase initialization error: $e");
  }

  // Start the app with all providers registered globally
  // Providers globally registered සමඟ App ආරම්භ කරයි
  runApp(
    MultiProvider(
      providers: [
        // AuthService: Raw Firebase Auth & Firestore calls
        // AuthService: Raw Firebase Auth & Firestore calls
        Provider<AuthService>(create: (_) => AuthService()),

        // FirestoreService: Raw Firestore database operations
        // FirestoreService: Raw Firestore database operations
        Provider<FirestoreService>(create: (_) => FirestoreService()),

        // AuthProvider: Manages login/logout state globally
        // AuthProvider: Login/logout state globally කළමනාකරණය කරයි
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

        // TicketProvider: Manages the list of events/tickets
        // TicketProvider: Events/tickets ලැයිස්තුව කළමනාකරණය කරයි
        ChangeNotifierProvider<TicketProvider>(create: (_) => TicketProvider()),

        // BookingProvider: Manages the current user's booking list
        // BookingProvider: වත්මන් user ගේ booking ලැයිස්තුව කළමනාකරණය කරයි
        ChangeNotifierProvider<BookingProvider>(
            create: (_) => BookingProvider()),

        // OrganizerProvider: Manages organizer-specific data
        // OrganizerProvider: Organizer-specific data කළමනාකරණය කරයි
        ChangeNotifierProvider<OrganizerProvider>(
            create: (_) => OrganizerProvider()),

        // ThemeProvider: Manages light/dark mode preference
        // ThemeProvider: ලා/අඳුරු තේමා මනාපය කළමනාකරණය කරයි
        ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ─── MyApp: Root widget of the application | Application හි Root widget ───────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MyTickets',
          // Theme configurations | තේමා සැකසුම්
          themeMode: themeProvider.themeMode,
          theme: AppTheme.userLightTheme(),
          darkTheme: AppTheme.userDarkTheme(),
          // Hide the debug banner in the top-right corner
      // ඉහළ-දකුණු කෙළවරේ debug banner සඟවයි
      debugShowCheckedModeBanner: false,
      // The initial route shown when the app starts
      // App ආරම්භ වූ විට දක්වන initial route
      initialRoute: '/',
      // Named routes — maps URL-like paths to Screen widgets
      // Named routes — URL-like paths Screen widgets ලෙසට map කරයි
      routes: {
        '/': (_) => const SplashScreen(),              // Splash/loading screen | Splash/loading screen
        '/home': (_) => const HomeScreen(),             // Main event listing | ප්‍රධාන event listing
        '/login': (_) => const LoginScreen(),           // Login/Register | Login/Register
        '/profile': (_) => const ProfileScreen(),       // User profile & bookings | User profile & bookings
        '/ticket': (_) => const TicketDetailScreen(),   // Event details & booking | Event details & booking
        '/organizer_dashboard': (_) => const OrganizerDashboardScreen(), // Organizer management | Organizer management
        '/create_event': (_) => const CreateEventScreen(), // Create new event | නව event සාදීම
        '/admin_login': (_) => const AdminLoginScreen(),   // Admin login | Admin login
        '/admin_panel': (_) => const AdminPanel(),         // Admin management panel | Admin management panel
        '/admin_users': (_) => const AdminUsersScreen(),   // Admin user list | Admin user list
        '/map_picker': (_) => const MapPickerScreen(),     // Location map picker | Location map picker
      },
    );
      },
    );
  }
}
