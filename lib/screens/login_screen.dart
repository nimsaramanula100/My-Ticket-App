import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user.dart' as user_model;

class LoginScreen extends StatefulWidget {
  final bool initialSignUp;

  const LoginScreen({Key? key, this.initialSignUp = false}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUpMode = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'user'; // 'user' or 'admin'

  @override
  void initState() {
    super.initState();
    _isSignUpMode = widget.initialSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = context.read<AuthService>();
        final user = await authService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (user != null && mounted) {
          final firestoreService = context.read<FirestoreService>();
          // If organizer/admin login selected, verify role in profile
          if (_selectedRole == 'admin') {
            final profile = await firestoreService.getUserProfile(user.uid);
            if (profile != null && profile.role == 'admin') {
              Navigator.of(context).pushReplacementNamed('/admin_panel');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('This account is not an organizer/admin.')),
              );
            }
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } catch (e) {
        if (mounted) {
          final msg = e.toString();
          final friendly =
              msg.contains('Firebase options are not configured') ||
                  msg.contains('Firebase options not provided') ||
                  msg.contains('CONFIGURATION_NOT_FOUND') ||
                  msg.toLowerCase().contains('configuration_not_found');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(friendly
                    ? 'Firebase configuration not found. Make sure you added the platform config (google-services.json / GoogleService-Info.plist) or run with --dart-define as described in README.'
                    : msg)),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = context.read<AuthService>();
        final firestoreService = context.read<FirestoreService>();

        final user = await authService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
        );

        if (user != null) {
          // Create user profile in Firestore
          final userProfile = user_model.User(
            id: user.uid,
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            profileImage: '',
            createdAt: DateTime.now(),
            role: _selectedRole == 'admin' ? 'admin' : 'user',
          );

          await firestoreService.createUserProfile(user.uid, userProfile);

          if (mounted) {
            if (_selectedRole == 'admin') {
              Navigator.of(context).pushReplacementNamed('/admin_panel');
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        }
      } catch (e) {
        if (mounted) {
          final msg = e.toString();
          final friendly =
              msg.contains('Firebase options are not configured') ||
                  msg.contains('Firebase options not provided') ||
                  msg.contains('CONFIGURATION_NOT_FOUND') ||
                  msg.toLowerCase().contains('configuration_not_found');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(friendly
                    ? 'Firebase configuration not found. Make sure you added the platform config (google-services.json / GoogleService-Info.plist) or run with --dart-define as described in README.'
                    : msg)),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade600, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_activity,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'MyTickets',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isSignUpMode ? 'Create Account' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isSignUpMode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildTextField(
                            _nameController,
                            'Full Name',
                            Icons.person,
                          ),
                        ),
                      // Role selector (User or Organizer)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('User'),
                                value: 'user',
                                groupValue: _selectedRole,
                                onChanged: (v) =>
                                    setState(() => _selectedRole = v!),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Organizer'),
                                value: 'admin',
                                groupValue: _selectedRole,
                                onChanged: (v) =>
                                    setState(() => _selectedRole = v!),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildTextField(
                          _emailController,
                          'Email',
                          Icons.email,
                        ),
                      ),
                      if (_isSignUpMode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildTextField(
                            _phoneController,
                            'Phone Number',
                            Icons.phone,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildTextField(
                          _passwordController,
                          'Password',
                          Icons.lock,
                          obscureText: true,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isSignUpMode ? _handleSignUp : _handleLogin),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isSignUpMode ? 'Sign Up' : 'Login',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isSignUpMode = !_isSignUpMode);
                            _formKey.currentState?.reset();
                          },
                          child: RichText(
                            text: TextSpan(
                              text: _isSignUpMode
                                  ? 'Already have an account? '
                                  : 'Don\'t have an account? ',
                              style: const TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: _isSignUpMode ? 'Login' : 'Sign Up',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (label == 'Email' &&
            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }
}
