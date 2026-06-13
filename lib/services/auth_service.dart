import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        return result.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      final code = e.code.toString().toLowerCase();
      if (code.contains('configuration') ||
          (e.message ?? '').contains('CONFIGURATION_NOT_FOUND')) {
        throw 'Firebase configuration not found. Ensure platform config files (google-services.json / GoogleService-Info.plist) are present or start the app with --dart-define credentials as described in README.';
      }
      throw e.message ?? e.toString();
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      final code = e.code.toString().toLowerCase();
      if (code.contains('configuration') ||
          (e.message ?? '').contains('CONFIGURATION_NOT_FOUND')) {
        throw 'Firebase configuration not found. Ensure platform config files (google-services.json / GoogleService-Info.plist) are present or start the app with --dart-define credentials as described in README.';
      }
      throw e.message ?? e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'email-already-in-use':
        return 'Email address is already in use.';
      case 'weak-password':
        return 'Password is not strong enough.';
      default:
        return e.message ?? 'An error occurred.';
    }
  }
}
