// lib/providers/auth_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// AuthProvider | සත්‍යාපන Provider
// Manages the authentication state of the entire app using ChangeNotifier.
// ChangeNotifier භාවිතා කරමින් App එකේ සත්‍යාපන තත්වය කළමනාකරණය කරයි.
// All screens listen to this provider to know if a user is logged in.
// සියලු screens, පරිශීලකයෙකු ලොගින් වී ඇත්දැයි දැන ගැනීමට මෙම provider හි ඇහුම්කන් දෙයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';
import '../services/auth_service.dart';

// ─── AuthProvider Class ───────────────────────────────────────────────────────
// Extends ChangeNotifier to allow UI widgets to rebuild when auth state changes.
// UI widgets auth state වෙනස් වූ විට නැවත ගොඩනැගීමට ChangeNotifier extend කරයි.
class AuthProvider extends ChangeNotifier {
  // Uses AuthService to interact with Firebase Auth and Firestore
  // Firebase Auth සහ Firestore සමඟ interact කිරීමට AuthService භාවිතා කරයි
  final AuthService _authService = AuthService();

  // Private state variables | පෞද්ගලික state variables
  AppUser? _appUser; // Current logged-in user data | දැනට ලොගින් වූ user දත්ත
  int _loadingCount =
      0; // Active async operation count | ක්‍රියාත්මක async මෙහෙයුම් සංඛ්‍යාව
  String?
      _error; // Stores the last error message | අවසාන error message ගබඩා කරයි

  // Public getters to expose state | State expose කිරීමට public getters
  AppUser? get appUser => _appUser;
  bool get isLoading => _loadingCount > 0;
  String? get error => _error;

  // Check if a user is currently signed in | පරිශීලකයෙකු දැනට sign in ව ඇත්ද
  bool get isSignedIn => _authService.isSignedIn;

  // The raw Firebase User object (can be null) | raw Firebase User object (null විය හැකි)
  fb.User? get firebaseUser => _authService.currentFirebaseUser;

  // Role of the current user, defaults to 'user' if no one is logged in
  // වත්මන් user ගේ role, කිසිවෙකු login නොවූ විට default 'user' වේ
  UserRole get role => _appUser?.role ?? UserRole.user;

  // Convenience role checkers | Role පරීක්ෂා කිරීමේ shortcuts
  bool get isOrganizer => role == UserRole.organizer;
  bool get isAdmin => role == UserRole.admin;

  // Constructor — starts listening to auth state changes immediately
  // Constructor — Authentication state changes වහාම listen කිරීම ආරම්භ කරයි
  AuthProvider() {
    _init();
  }

  // ─── _init: Listen to Firebase auth state stream ─────────────────────────────
  // Whenever Firebase Auth signals a login or logout, this method responds.
  // Firebase Auth login හෝ logout signal කරන සෑම විටෙකම, මෙම method respond කරයි.
  void _init() {
    _authService.authStateChanges.listen((fbUser) async {
      if (fbUser == null) {
        // User has signed out — clear local user data
        // User sign out කළා — local user data ඉවත් කරයි
        _appUser = null;
        notifyListeners();
      } else {
        // User signed in — load their profile from Firestore
        // User sign in කළා — Firestore වලින් ඔවුන්ගේ profile load කරයි
        await _loadUserProfile(fbUser.uid);
      }
    });
  }

  // ─── _loadUserProfile: Fetches user data from Firestore ───────────────────────
  // Called after login/register to get the user's app-level profile.
  // Login/register පසු user ගේ app-level profile ගැනීමට call කරයි.
  Future<void> _loadUserProfile(String uid) async {
    _setLoading(true);
    _error = null;
    try {
      // Fetch user profile with a 10-second timeout to avoid hanging
      // Hang වීම වළකීමට 10-second timeout සමඟ user profile ලබා ගනී
      _appUser = await _authService
          .getAppUser(uid)
          .timeout(const Duration(seconds: 10));
      if (_appUser == null) {
        _error = "User profile not found.";
      }
    } catch (e) {
      _error = "Failed to load profile: $e";
    } finally {
      // Always stop loading whether success or failure
      // සාර්ථකත්වය හෝ අසාර්ථකත්වය, loading සැමවිටම නිවා දමයි
      _setLoading(false);
    }
  }

  // ─── signIn: Log in with email and password ───────────────────────────────────
  // Returns true on success, false on error.
  // සාර්ථකව ලොගින් වූ විට true, error ඇති විට false ලබා දෙයි.
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      final fbUser = _authService.currentFirebaseUser;
      if (fbUser != null) {
        // Load profile from Firestore after successful Firebase sign in
        // Firebase sign in සාර්ථක වූ පසු Firestore වලින් profile load කරයි
        await _loadUserProfile(fbUser.uid);
      }
      _error = null;
      return true;
    } catch (e) {
      // Convert technical error to a user-friendly message
      // Technical error user-friendly message බවට හරවයි
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── registerUser: Create a new regular user account ─────────────────────────
  // Creates both Firebase Auth and Firestore user records.
  // Firebase Auth සහ Firestore user records දෙකම නිර්මාණය කරයි.
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _setLoading(true);
    try {
      await _authService.registerUser(
          name: name, email: email, password: password, phone: phone);
      final fbUser = _authService.currentFirebaseUser;
      if (fbUser != null) {
        await _loadUserProfile(fbUser.uid);
      }
      _error = null;
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── registerOrganizer: Create a new organizer account ───────────────────────
  // Creates Firebase Auth, Firestore user, AND Firestore organizer documents.
  // Firebase Auth, Firestore user, හා Firestore organizer ලේඛන නිර්මාණය කරයි.
  Future<bool> registerOrganizer({
    required String name,
    required String email,
    required String password,
    required String orgName,
    required String phone,
    String bio = '',
  }) async {
    _setLoading(true);
    try {
      await _authService.registerOrganizer(
        name: name,
        email: email,
        password: password,
        orgName: orgName,
        phone: phone,
        bio: bio,
      );
      final fbUser = _authService.currentFirebaseUser;
      if (fbUser != null) {
        await _loadUserProfile(fbUser.uid);
      }
      _error = null;
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── signOut: Log the current user out ───────────────────────────────────────
  // Clears local user data and notifies all listeners.
  // Local user data ඉවත් කර සියලු listeners ට දන්වයි.
  Future<void> signOut() async {
    await _authService.signOut();
    _appUser = null;
    notifyListeners();
  }

  // ─── deleteAccount: Permanently delete the user's Firebase account ────────────
  // This also clears the local user data.
  // මෙය local user data ද ඉවත් කරයි.
  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    _appUser = null;
    notifyListeners();
  }

  // ─── sendPasswordReset: Send a password reset email ──────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ─── clearError: Dismiss the current error message ───────────────────────────
  // Called by the UI after showing the error so it's not shown again.
  // Error දෙකරවතාවක් නොදැක්වීමට error දැක්වූ පසු UI විසින් call කරයි.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Helper: Set loading state ────────────────────────────────────────────────
  void _setLoading(bool v) {
    if (v) {
      _loadingCount++;
    } else if (_loadingCount > 0) {
      _loadingCount--;
    }
    notifyListeners();
  }

  // ─── Helper: Convert Firebase error codes to readable messages ────────────────
  // Translates technical Firebase error codes into user-friendly strings.
  // Technical Firebase error codes user-friendly strings බවට පරිවර්තනය කරයි.
  String _friendlyError(Object e) {
    final errorMessage = e.toString();
    if (errorMessage.contains('wrong-password') ||
        errorMessage.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (errorMessage.contains('timed out') ||
        errorMessage.contains('TimeoutException')) {
      return 'Request timed out. Check your internet connection and try again.';
    }
    if (errorMessage.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (errorMessage.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (errorMessage.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (errorMessage.contains('network-request-failed')) {
      return 'No internet connection. Please try again.';
    }
    // Generic fallback message | Generic fallback message
    return 'Something went wrong. Please try again. ($e)';
  }
}
