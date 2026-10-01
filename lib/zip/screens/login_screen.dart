// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/organizer_provider.dart';
import '../models/user.dart';
import '../theme/color_palette.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeyUser = GlobalKey<FormState>();
  final _formKeyOrg = GlobalKey<FormState>();

  // Input Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Clear forms and reset signup mode when switching tabs
      setState(() {
        _isSignUp = false;
        _clearControllers();
      });
    });
  }

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _orgNameController.clear();
    _bioController.clear();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _orgNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isOrganizer) async {
    final formKey = isOrganizer ? _formKeyOrg : _formKeyUser;
    if (!formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizerProvider>();

    bool success = false;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (isOrganizer) {
      if (_isSignUp) {
        success = await auth.registerOrganizer(
          name: _nameController.text.trim(),
          email: email,
          password: password,
          orgName: _orgNameController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
        );
      } else {
        success = await auth.signIn(email, password);
      }
    } else {
      if (_isSignUp) {
        success = await auth.registerUser(
          name: _nameController.text.trim(),
          email: email,
          password: password,
          phone: _phoneController.text.trim(),
        );
      } else {
        success = await auth.signIn(email, password);
      }
    }

    if (!mounted) return;

    if (success) {
      final role = auth.role;
      if (role == UserRole.organizer) {
        final orgId = auth.appUser?.organizerId;
        if (orgId != null) {
          await orgProvider.initialize(orgId);
          if (!mounted) return;
        }
        Navigator.of(context).pushReplacementNamed('/organizer_dashboard');
      } else if (role == UserRole.admin) {
        Navigator.of(context).pushReplacementNamed('/admin_panel');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Authentication failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final primaryColor = _tabController.index == 1 
        ? AppColors.organizerAccent 
        : AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MyTickets.lk'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'User Account'),
            Tab(icon: Icon(Icons.business), text: 'Organizer'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // User login/signup Tab
            _buildAuthForm(isOrganizer: false, formKey: _formKeyUser, isLoading: isLoading, accentColor: AppColors.accent),
            // Organizer login/signup Tab
            _buildAuthForm(isOrganizer: true, formKey: _formKeyOrg, isLoading: isLoading, accentColor: AppColors.organizerAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm({
    required bool isOrganizer,
    required GlobalKey<FormState> formKey,
    required bool isLoading,
    required Color accentColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // App Branding Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOrganizer ? Icons.business : Icons.local_activity,
                  size: 64,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _isSignUp 
                    ? (isOrganizer ? 'Create Organizer Account' : 'Join MyTickets.lk')
                    : (isOrganizer ? 'Organizer Portal' : 'Welcome Back'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _isSignUp 
                    ? 'Fill in the details below to register'
                    : 'Sign in to access your account',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            if (_isSignUp) ...[
              // Full Name field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),

              // Organization Name field (organizer only)
              if (isOrganizer) ...[
                TextFormField(
                  controller: _orgNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter organization name' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Phone field
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 16),

              // Short Bio field (organizer only)
              if (isOrganizer) ...[
                TextFormField(
                  controller: _bioController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Organizer Bio / Details',
                    prefixIcon: Icon(Icons.info_outline),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // Email Address field
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter email';
                final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                if (!emailRegExp.hasMatch(val.trim())) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),

            // Confirm Password (signup only)
            if (_isSignUp) ...[
              TextFormField(
                controller: _confirmPasswordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (val) {
                  if (val != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Implement password reset if desired
                    if (_emailController.text.trim().isNotEmpty) {
                      context.read<AuthProvider>().sendPasswordReset(_emailController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password reset email sent!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your email first')),
                      );
                    }
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Submit Button
            ElevatedButton(
              onPressed: isLoading ? null : () => _submit(isOrganizer),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : Text(
                      _isSignUp ? 'Sign Up' : 'Log In',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),

            // Switch Login/Signup Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _formKeyUser.currentState?.reset();
                      _formKeyOrg.currentState?.reset();
                    });
                  },
                  child: Text(
                    _isSignUp ? 'Log In' : 'Sign Up',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
