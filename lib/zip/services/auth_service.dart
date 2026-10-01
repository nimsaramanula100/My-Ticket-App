// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Auth State Stream ──────────────────────────────────────
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();
  fb_auth.User? get currentFirebaseUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  // ─── Sign In with Email & Password ─────────────────────────
  Future<fb_auth.User?> signIn(
      {required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Log technical codes (e.g., 'invalid-credential', 'user-disabled') for debugging
      debugPrint('AuthService.signIn: ${e.code} - ${e.message}');
      // Rethrowing allows the UI layer to catch this and show a specific error message
      rethrow;
    } catch (e) {
      debugPrint('AuthService.signIn: An unexpected error occurred: $e');
      rethrow;
    }
  }

  // ─── Register User ──────────────────────────────────────────
  Future<fb_auth.User?> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user profile in Firestore
      final appUser = AppUser(
        id: firebaseUser.uid,
        name: name,
        email: email.trim(),
        phone: phone,
        role: UserRole.user,
      );
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(appUser.toMap());

      return firebaseUser;
    } catch (e) {
      debugPrint('AuthService.registerUser: $e');
      rethrow;
    }
  }

  // ─── Register Organizer ─────────────────────────────────────
  Future<fb_auth.User?> registerOrganizer({
    required String name,
    required String email,
    required String password,
    required String orgName,
    required String phone,
    String bio = '',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) return null;

    await firebaseUser.updateDisplayName(name);

    // Create organizer document
    final organizerRef = _firestore.collection('organizers').doc();
    await organizerRef.set({
      'userId': firebaseUser.uid,
      'name': orgName,
      'email': email.trim(),
      'phone': phone,
      'bio': bio,
      'profileImage': '',
      'verificationStatus': 'verified', // Auto-approve for now
      'eventsCount': 0,
      'totalRevenue': 0.0,
      'totalAttendees': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'socialLinks': [],
    });

    // Create user profile with organizer role
    final appUser = AppUser(
      id: firebaseUser.uid,
      name: name,
      email: email.trim(),
      phone: phone,
      role: UserRole.organizer,
      organizerId: organizerRef.id,
    );
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(appUser.toMap());

    return firebaseUser;
  }

  // ─── Get User Role ──────────────────────────────────────────
  Future<UserRole> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return UserRole.user;
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

  // ─── Get AppUser Profile ────────────────────────────────────
  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, uid);
  }

  // ─── Sign Out ───────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ─── Send Password Reset ────────────────────────────────────
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ─── Update Password ────────────────────────────────────────
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }
}
