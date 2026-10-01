// lib/screens/admin_login_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// AdminLoginScreen | පරිපාලක ලොගින් තිරය (Admin Login Screen)
// A secure login screen accessible only to admin users.
// Validates credentials against Firebase Auth and checks the Firestore role
// before permitting navigation to the admin panel.
// ෆයර්බේස් Auth සමඟ අගය-නිරාකරණය කර ෆයර්ස්ටෝර් (Firestore) භූමිකාව
// සත්‍යාපනය කිරීමෙන් පසු පරිපාලක (admin) ලෙස ප්‍රවේශය ලබා දෙයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user.dart' as user_model;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // ─── Form State | පෝරම තත්වය ───────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>(); // Validates form before submit | ඉදිරිපත් කිරීමට පෙර පෝරමය සත්‍යාපනය කරයි
  final _emailController = TextEditingController();    // Admin email input | ඊමේල් ආදානය
  final _passwordController = TextEditingController(); // Admin password input | මුරපදය ආදානය
  bool _isLoading = false; // Disables button during auth | ප්‍රමාණීකරණ අතරතුර බොත්තම අක්‍රිය කරයි

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    // මතකය නාස්ති නොවීමට controllers dispose කරයි
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── _handleAdminLogin: Authenticate and check admin role ─────────────────
  // _handleAdminLogin: ප්‍රමාණීකරණය කර admin භූමිකාව සත්‍යාපනය කරයි
  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid | ආදානය අවලංගු නම් ඉදිරියට නොයෙදෙයි
    }
    setState(() => _isLoading = true); // Show loading state | Loading තත්වය පෙන්වයි
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();

      // Step 1: Firebase Auth sign-in | 1. Firebase Auth ලොගිනය
      final user = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // Step 2: Load Firestore user profile | 2. Firestore හි පරිශීලක ව්‍යාපෘතිය ලබා ගනී
        final profile = await firestoreService.getUserProfile(user.uid);
        // Step 3: Confirm role is admin | 3. භූමිකාව admin දැයි සත්‍යාපනය කරයි
        if (profile != null && profile.role == user_model.UserRole.admin) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/admin_panel');
          }
          return;
        }
        // Non-admin account — reject | Admin නොවන ගිණුම — ප්‍රතික්ෂේප කරයි
        throw 'Not an admin account.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Always restore button | සෑම විටම බොත්තම නැවත සක්‍රීය කරයි
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email field | ඊමේල් ක්ෂේත්‍රය
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 12),
              // Password field | මුරපද ක්ෂේත්‍රය
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              // Submit button — disabled while loading | ඉදිරිපත් කිරීමේ බොත්තම — Loading අතරතුර අක්‍රිය
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAdminLogin,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login as Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
