// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _appUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSignedIn => _authService.isSignedIn;
  fb.User? get firebaseUser => _authService.currentFirebaseUser;
  UserRole get role => _appUser?.role ?? UserRole.user;
  bool get isOrganizer => role == UserRole.organizer;
  bool get isAdmin => role == UserRole.admin;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((fbUser) async {
      if (fbUser == null) {
        _appUser = null;
        notifyListeners();
      } else {
        await _loadUserProfile(fbUser.uid);
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _appUser = await _authService.getAppUser(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
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

  Future<void> signOut() async {
    await _authService.signOut();
    _appUser = null;
    notifyListeners();
  }

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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _friendlyError(String e) {
    if (e.contains('wrong-password') || e.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (e.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (e.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (e.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (e.contains('network-request-failed')) {
      return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again. ($e)';
  }
}
