import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/admin_users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase:
  // - On web we must provide options (from dart-define or generated file)
  // - On native platforms, Firebase will read platform config files
  //   (google-services.json / GoogleService-Info.plist) if present.
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Missing web options — app will run but Firebase features will be disabled.
      // Provide credentials via --dart-define or generate lib/firebase_options.dart.
      // ignore: avoid_print
      print('Warning: Firebase web options not provided: $e');
    }
  } else {
    try {
      await Firebase.initializeApp();
      // Activate App Check in debug mode so the native SDK sends a debug
      // App Check token during development. This prevents the server from
      // rejecting connections when App Check enforcement is enabled.
      if (kDebugMode && !kIsWeb) {
        try {
          await FirebaseAppCheck.instance
              .activate(androidProvider: AndroidProvider.debug);
        } catch (e) {
          // ignore: avoid_print
          print('Warning: Firebase App Check activation failed: $e');
        }
      }
    } catch (e) {
      // If native initialization fails, attempt to initialize from
      // `DefaultFirebaseOptions`. If that is not configured we'll
      // catch the error and continue running the app (Firebase
      // features will be disabled). This prevents StateError from
      // bubbling up into UI flows such as sign up.
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e2) {
        // ignore: avoid_print
        print('Warning: Firebase initialization failed: $e2');
      }
    }
  }
  // RTDB smoke test in debug mode
  if (kDebugMode) {
    try {
      final db = FirebaseDatabase.instance;
      await db
          .ref('smoke_test')
          .set({'initialized': DateTime.now().toIso8601String()});
      final snapshot = await db.ref('smoke_test').get();
      // ignore: avoid_print
      print('RTDB smoke_test -> ${snapshot.value}');
    } catch (e) {
      // ignore: avoid_print
      print('RTDB smoke test failed: $e');
    }
  }
  runApp(const MyTicketsApp());
}

class MyTicketsApp extends StatelessWidget {
  const MyTicketsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'MyTickets',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        // Start the app on the splash screen which will route to login/home
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin': (context) => const AdminLoginScreen(),
          '/admin_panel': (context) => const AdminPanel(),
          '/admin_users': (context) => const AdminUsersScreen(),
        },
      ),
    );
  }
}

// Import screens here to avoid circular imports
