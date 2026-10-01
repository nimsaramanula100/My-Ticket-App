// lib/screens/login_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen | ලොගින් තිරය (Authentication Screen)
// Dual-tab login & signup screen for both User and Organizer accounts.
// Tab switching resets forms. Submit routes to the correct dashboard based on role.
// පරිශීලක (User) සහ සංවිධායක (Organizer) ගිණුම් සඳහා ද්විත්ව-ටැබ් ලොගින් & ලියාපදිංචි තිරය.
// ටැබ් ස්විච් කළ විට පෝරම නිර්මල වේ. ඉදිරිපත් කිරීමෙන් භූමිකාව අනුව නිවැරදි dashboard ට යෙදෙයි.
// ─────────────────────────────────────────────────────────────────────────────
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

// Uses SingleTickerProviderStateMixin for TabController vsync
// TabController vsync සඳහා SingleTickerProviderStateMixin භාවිත කරයි
class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // ─── Tab & Form Keys | ටැබ් සහ පෝරම යතුරු ───────────────────────────────
  late TabController _tabController; // Manages User / Organizer tabs | User / Organizer ටැබ් කළමනාකරණය
  final _formKeyUser = GlobalKey<FormState>(); // User tab form key | පරිශීලක ටැබ් පෝරම යතුර
  final _formKeyOrg = GlobalKey<FormState>();  // Organizer tab form key | සංවිධායක ටැබ් පෝරම යතුර

  // ─── Input Controllers | ආදාන පාලක ─────────────────────────────────────────
  final _nameController = TextEditingController();            // Full name | සම්පූර්ණ නම
  final _emailController = TextEditingController();           // Email address | ඊමේල් ලිපිනය
  final _passwordController = TextEditingController();        // Password | මුරපදය
  final _confirmPasswordController = TextEditingController(); // Confirm password (signup) | මුරපදය තහවුරු කිරීම
  final _phoneController = TextEditingController();           // Phone number | දුරකථන අංකය
  final _orgNameController = TextEditingController();         // Organization name (organizer) | සංවිධාව නම
  final _bioController = TextEditingController();             // Short bio (organizer) | කෙටි හැඳිනීම

  // ─── UI State Flags | UI තත්ව ලකුණු ─────────────────────────────────────────
  bool _isSignUp = false;               // Toggle between login & signup | ලොගිනය සහ ලියාපදිංචිය අතර
  bool _obscurePassword = true;         // Hide/show password | මුරපදය සඟවයි/පෙන්වයි
  bool _obscureConfirmPassword = true;  // Hide/show confirm password | තහවුරු මුරපදය සඟවයි/පෙන්වයි

  @override
  void initState() {
    super.initState();
    // Create TabController with 2 tabs (User, Organizer)
    // ටැබ් 2 ක් (User, Organizer) සහිත TabController ගොඩනඟයි
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // When tab switches, reset signup mode and clear all fields
      // ටැබ් මාරු වූ විට signup mode නැවත සකසා සියළු ක්ෂේත්‍ර හිස් කරයි
      setState(() {
        _isSignUp = false;
        _clearControllers();
      });
    });
  }

  // ─── _clearControllers: Reset all text input fields | සියළු ආදාන ක්ෂේත්‍ර හිස් කරයි ──
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
    // Dispose all controllers and tab controller to prevent memory leaks
    // මතකය නාස්ති නොවීමට සියළු controllers dispose කරයි
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

  // ─── _submit: Handle login/register and navigate based on role ──────────
  // _submit: ලොගිනය/ලියාපදිංචිය සහ role-based navigation කළමනාකරණය
  Future<void> _submit(bool isOrganizer) async {
    final formKey = isOrganizer ? _formKeyOrg : _formKeyUser;
    if (!formKey.currentState!.validate()) return; // Validate form | පෝරමය සත්‍යාපනය

    final auth = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizerProvider>();

    bool success = false;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (isOrganizer) {
      if (_isSignUp) {
        // Register new organizer account | නව සංවිධායක ගිණුමක් ලියාපදිංචි කරයි
        success = await auth.registerOrganizer(
          name: _nameController.text.trim(),
          email: email,
          password: password,
          orgName: _orgNameController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
        );
      } else {
        // Sign in existing organizer | පවත්නා සංවිධායකයෙකු ලොගිනය කරයි
        success = await auth.signIn(email, password);
      }
    } else {
      if (_isSignUp) {
        // Register new regular user | නව සාමාන්‍ය පරිශීලකයෙකු ලියාපදිංචි කරයි
        success = await auth.registerUser(
          name: _nameController.text.trim(),
          email: email,
          password: password,
          phone: _phoneController.text.trim(),
        );
      } else {
        // Sign in existing user | පවත්නා පරිශීලකයෙකු ලොගිනය කරයි
        success = await auth.signIn(email, password);
      }
    }

    if (!mounted) return;

    if (success) {
      // Navigate based on authenticated user role
      // ප්‍රමාණීකරණ භූමිකාව (role) අනුව නිවැරදි dashboard ට යෙදෙයි
      final role = auth.role;
      if (role == UserRole.organizer) {
        final orgId = auth.appUser?.organizerId;
        if (orgId != null) {
          await orgProvider.initialize(orgId); // Pre-load organizer data | සංවිධායක දත්ත කලින් ලෝඩ් කරයි
          if (!mounted) return;
        }
        Navigator.of(context).pushReplacementNamed('/organizer_dashboard');
      } else if (role == UserRole.admin) {
        Navigator.of(context).pushReplacementNamed('/admin_panel');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Show error snackbar if auth fails | ප්‍රමාණීකරණය අසාර්ථක නම් දෝෂ Snackbar
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
    // Watch loading state from AuthProvider | AuthProvider හි loading තත්වය නිරීක්ෂණය
    final isLoading = context.watch<AuthProvider>().isLoading;
    // Active tab's accent color (user=blue, organizer=orange)
    // ක්‍රියාශීලී ටැබ්හි වර්ණය (user=නිල්, organizer=තැඹිලි)
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
            // User login/signup tab | පරිශීලක ලොගිනය/ලියාපදිංචිය ටැබ්
            _buildAuthForm(isOrganizer: false, formKey: _formKeyUser, isLoading: isLoading, accentColor: AppColors.accent),
            // Organizer login/signup tab | සංවිධායක ලොගිනය/ලියාපදිංචිය ටැබ්
            _buildAuthForm(isOrganizer: true, formKey: _formKeyOrg, isLoading: isLoading, accentColor: AppColors.organizerAccent),
          ],
        ),
      ),
    );
  }

  // ─── _buildAuthForm: Shared form builder for both tabs ──────────────────
  // _buildAuthForm: ටැබ් දෙකම සඳහා පොදු පෝරම ගොඩනිව්ම
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
            // Branding icon — changes based on account type
            // සිරුරු නිරූපකය — ගිණුම් වර්ගය අනුව වෙනස් වේ
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
            // Title — changes between signup/login and user/organizer
            // මාතෘකාව — signup/login සහ user/organizer අනුව වෙනස් වේ
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
            // Subtitle | උප මාතෘකාව
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

            // ── Signup-only fields (shown only when _isSignUp is true) ──────
            // ── ලියාපදිංචිය-පමණ ක්ෂේත්‍ර (_isSignUp=true ලදී) ──────────────
            if (_isSignUp) ...[
              // Full name | සම්පූර්ණ නම
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

              // Organization name (organizer accounts only)
              // සංවිධා නම (සංවිධායක ගිණුම් සඳහා පමණක්)
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

              // Phone number | දුරකථන අංකය
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

              // Short bio (organizer accounts only)
              // කෙටි හැඳිනීම (සංවිධායක ගිණුම් සඳහා පමණක්)
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

            // ── Email field (always visible) | ඊමේල් ක්ෂේත්‍රය (සෑම විටම දෘශ්‍ය) ──
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
                // Simple regex validation for email format
                // ඊමේල් ආකෘතිය සරල regex හරහා සත්‍යාපනය කරයි
                final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                if (!emailRegExp.hasMatch(val.trim())) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Password field with toggle visibility | දෘශ්‍යතා ටොගල් සහිත මුරපද ─
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  // Eye icon toggles password visibility
                  // ඇස් නිරූපකය මුරපදය සඟවයි/පෙන්වයි
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),

            // ── Signup: Confirm Password | ── ලියාපදිංචිය: මුරපදය තහවුරු ──────
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
                // Check that both passwords match | මුරපද දෙකම ගැළපෙන දැයි සත්‍යාපනය
                validator: (val) {
                  if (val != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 12),
              // Forgot password button (login mode only)
              // "මුරපදය අමතකද?" බොත්තම (ලොගිනය ප්‍රකාරයේදී පමණක්)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (_emailController.text.trim().isNotEmpty) {
                      // Trigger Firebase password reset email
                      // Firebase මුරපද reset ඊමේලය යවයි
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

            // ── Submit Button | ── ඉදිරිපත් කිරීමේ බොත්තම ────────────────────
            ElevatedButton(
              onPressed: isLoading ? null : () => _submit(isOrganizer),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              // Show spinner while loading, text otherwise
              // Loading අතරතුර spinner, නැතිනම් බොත්තම් පෙළ
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

            // ── Login/Signup toggle link | ── ලොගිනය/ලියාපදිංචිය ස්විච් ─────
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
                      _isSignUp = !_isSignUp; // Toggle mode | ප්‍රකාරය මාරු කරයි
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
