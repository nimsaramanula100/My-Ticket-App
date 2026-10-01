// lib/services/auth_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// AuthService | සත්‍යාපන සේවාව
// This is the low-level service that directly communicates with Firebase Auth
// and Firestore to handle user registration, login, logout, etc.
// Firebase Auth සහ Firestore සමඟ directly communicate කරන low-level service.
// User registration, login, logout ආදිය handle කිරීම සඳහා.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService {
  // Firebase Auth instance — used for login/logout/register
  // Login/logout/register සඳහා Firebase Auth instance
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  // Firestore instance — used to read and write user profiles
  // User profiles කියවීමට/ලිවීමට Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Auth State Stream | සත්‍යාපන State Stream ───────────────────────────────
  // A stream that emits a User whenever the auth state changes (login/logout).
  // Auth state (login/logout) වෙනස් වූ සෑම විටෙකම User emit කරන stream.
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  // The currently authenticated Firebase User (null if signed out)
  // දැනට authenticate කළ Firebase User (sign out නම් null)
  fb_auth.User? get currentFirebaseUser => _auth.currentUser;

  // True if any user is currently signed in | කිසිවෙකු sign in ව ඇත්නම් true
  bool get isSignedIn => _auth.currentUser != null;

  // ─── signIn: Log in with email & password ─────────────────────────────────────
  // Signs in to Firebase Auth and returns the Firebase User.
  // Firebase Auth හරහා login කර Firebase User ලබා දෙයි.
  Future<fb_auth.User?> signIn(
      {required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Log technical codes for debugging (e.g., 'invalid-credential')
      // Debugging සඳහා technical codes log කරයි (e.g., 'invalid-credential')
      debugPrint('AuthService.signIn: ${e.code} - ${e.message}');
      // Re-throw so the UI layer can show the right message
      // UI layer හට නිවැරදි message දෙකරවීමට re-throw කරයි
      rethrow;
    } catch (e) {
      // Some Android versions throw a Pigeon type-cast bug after successful auth.
      // Some Android versions auth සාර්ථකව ව්ද පසු Pigeon type-cast bug throw කරයි.
      // This bypass checks for that and gracefully returns the current user.
      // මෙම bypass ඒ සඳහා check කර gracefully current user ලබා දෙයි.
      if (e.toString().contains('PigeonUserDetails')) {
        debugPrint('AuthService.signIn: Pigeon bug bypassed.');
        return _auth.currentUser;
      }
      debugPrint('AuthService.signIn: An unexpected error occurred: $e');
      rethrow;
    }
  }

  // ─── registerUser: Create a new regular user account ─────────────────────────
  // Step 1: Create Firebase Auth account.
  // Step 2: Create a user document in Firestore with role='user'.
  // Step 1: Firebase Auth ගිණුම සාදයි.
  // Step 2: role='user' සහිත Firestore user ලේඛනයක් සාදයි.
  Future<fb_auth.User?> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      fb_auth.User? firebaseUser;
      try {
        // Create the Firebase Auth user account
        // Firebase Auth user ගිණුම සාදයි
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        firebaseUser = credential.user;
      } catch (e) {
        // Handle Pigeon bug on some Android builds
        // Some Android builds හි Pigeon bug handle කරයි
        if (e.toString().contains('PigeonUserDetails')) {
          debugPrint('AuthService.registerUser: Pigeon bug bypassed.');
          firebaseUser = _auth.currentUser;
        } else {
          rethrow;
        }
      }
      
      // If user creation failed for any reason, abort
      // User නිර්මාණය fail වූ නම් abort කරයි
      if (firebaseUser == null) return null;

      try {
        // Update the Firebase display name (best-effort)
        // Firebase display name update කරයි (best-effort — failure ignored)
        try {
          await firebaseUser.updateDisplayName(name);
        } catch (e) {
          debugPrint('AuthService: updateDisplayName failed, ignoring: $e');
        }

        // Create the user's app-level profile in Firestore
        // Firestore හි user ගේ app-level profile නිර්මාණය කරයි
        final appUser = AppUser(
          id: firebaseUser.uid,
          name: name,
          email: email.trim(),
          phone: phone,
          role: UserRole.user, // Regular user role | සාමාන්‍ය user role
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(appUser.toMap());

        return firebaseUser;
      } catch (e) {
        // If Firestore write fails, delete the Firebase Auth user to keep data consistent
        // Firestore write fail නම්, data consistent ලෙස තබා ගැනීමට Firebase Auth user delete කරයි
        await firebaseUser.delete();
        rethrow;
      }
    } catch (e) {
      debugPrint('AuthService.registerUser: $e');
      rethrow;
    }
  }

  // ─── registerOrganizer: Create an organizer account ──────────────────────────
  // Step 1: Create Firebase Auth account.
  // Step 2: Create Firestore 'organizers' document.
  // Step 3: Create Firestore 'users' document with role='organizer'.
  // Step 1: Firebase Auth ගිණුම සාදයි.
  // Step 2: Firestore 'organizers' ලේඛනය සාදයි.
  // Step 3: role='organizer' සහිත Firestore 'users' ලේඛනය සාදයි.
  Future<fb_auth.User?> registerOrganizer({
    required String name,
    required String email,
    required String password,
    required String orgName,
    required String phone,
    String bio = '',
  }) async {
    try {
      fb_auth.User? firebaseUser;
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        firebaseUser = credential.user;
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails')) {
          debugPrint('AuthService.registerOrganizer: Pigeon bug bypassed.');
          firebaseUser = _auth.currentUser;
        } else {
          rethrow;
        }
      }
      
      if (firebaseUser == null) return null;

      try {
        try {
          await firebaseUser.updateDisplayName(name);
        } catch (e) {
          debugPrint('AuthService: updateDisplayName failed, ignoring: $e');
        }

        // Create a new organizer document in Firestore's 'organizers' collection
        // Firestore 'organizers' collection හි නව organizer ලේඛනයක් සාදයි
        final organizerRef = _firestore.collection('organizers').doc();
        await organizerRef.set({
          'userId': firebaseUser.uid,
          'name': orgName,
          'email': email.trim(),
          'phone': phone,
          'bio': bio,
          'profileImage': '',
          'verificationStatus': 'verified', // Auto-approve for now | දැනට ස්වයංක්‍රීයව අනුමත කරයි
          'eventsCount': 0,
          'totalRevenue': 0.0,
          'totalAttendees': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'socialLinks': [],
        });

        // Create the user profile with organizer role and link to organizer doc
        // Organizer role සහ organizer doc link සහිත user profile නිර්මාණය කරයි
        final appUser = AppUser(
          id: firebaseUser.uid,
          name: name,
          email: email.trim(),
          phone: phone,
          role: UserRole.organizer,
          organizerId: organizerRef.id, // Link to the organizer document | organizer ලේඛනයට link
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(appUser.toMap());

        return firebaseUser;
      } catch (e) {
        // Rollback: delete the Firebase Auth user if Firestore writes fail
        // Rollback: Firestore writes fail නම් Firebase Auth user delete කරයි
        await firebaseUser.delete();
        rethrow;
      }
    } catch (e) {
      debugPrint('AuthService.registerOrganizer: $e');
      rethrow;
    }
  }

  // ─── getUserRole: Fetch the role of a user by UID ────────────────────────────
  // Reads a single Firestore document and returns the role enum value.
  // Firestore ලේඛනයක් කියවා role enum value ලබා දෙයි.
  Future<UserRole> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return UserRole.user; // Default if not found | නොමැතිනම් default user
    final data = doc.data()!;
    switch (data['role']) {
      case 'organizer':
        return UserRole.organizer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  // ─── getAppUser: Fetch the full AppUser profile by UID ───────────────────────
  // Returns null if no user document exists in Firestore.
  // Firestore හි user ලේඛනය නොමැතිනම් null ලබා දෙයි.
  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, uid);
  }

  // ─── signOut: Log out the current user ───────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ─── deleteAccount: Permanently remove the Firebase Auth account ──────────────
  // Warning: This cannot be undone! | අනතුරු ඇඟවීම: මෙය undo කළ නොහැකිය!
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  // ─── sendPasswordReset: Email a password reset link ──────────────────────────
  // Firebase sends a reset email to the provided address.
  // Firebase සපයූ ලිපිනයට reset email එකක් යවයි.
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ─── updatePassword: Change the user's password ──────────────────────────────
  // The user must be recently re-authenticated for this to work.
  // මෙය ක්‍රියා කිරීමට user ට මෑතකදී re-authenticate කළ යුතු වේ.
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }
}
