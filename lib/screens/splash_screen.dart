// lib/screens/splash_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen | ආරම්භක තිරය (App Launch / Splash Screen)
// First screen shown on app launch. Plays logo animations and routes the user
// to the appropriate screen based on authentication role.
// යෙදුම ආරම්භ වූ විට දර්ශනය වන පළමු තිරය. ලාංජනය (logo) ජීව්‍රිත කර
// ප්‍රමාණීකරණ භූමිකාව (auth role) අනුව නිවැරදි තිරයට යොමු කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../theme/color_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Uses SingleTickerProviderStateMixin to provide vsync for AnimationController
// AnimationController සඳහා vsync ලබා ගැනීමට SingleTickerProviderStateMixin භාවිතා කරයි
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ─── Animation Controllers | ජීව්‍රිතකරණ පාලක ─────────────────────────────────
  late AnimationController _controller; // Drives all animations | සියළු ජීව්‍රිතන ධාවනය කරයි
  late Animation<double> _fadeAnimation;  // Opacity fade 0.0 → 1.0 | දෘශ්‍යතා ජීව්‍රිතය
  late Animation<double> _scaleAnimation; // Scale 0.7 → 1.0 | ප්‍රමාණ ජීව්‍රිතය

  @override
  void initState() {
    super.initState();
    // Create controller with 1200ms total animation duration
    // 1200ms ක් සඳහා ජීව්‍රිතකරණ පාලකය ආරම්භ කරයි
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation runs from 0% to 60% of total duration
    // ශීර්ෂ ජීව්‍රිතය සමස්ත කාලයෙන් 0% සිට 60% දක්වා ධාවනය වේ
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Scale animation runs from 0% to 60% of total duration
    // ප්‍රමාණ ජීව්‍රිතය ද 0% සිට 60% දක්වා ධාවනය වේ (zoom-in effect)
    _scaleAnimation =
        Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Start animations playing forward
    // ජීව්‍රිතන ඉදිරි දිශාවට ධාවනය කිරීම ආරම්භ කරයි
    _controller.forward();

    // Navigate after 2 seconds | තත්පර 2 කට පසු නිවැරදි තිරයට යොමු කරයි
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  // ─── _navigate: Role-based navigation | භූමිකාව අනුව නිවැරදි තිරයට යොමු කිරීම ──
  void _navigate() {
    if (!mounted) return; // Safety guard after async delay | async ප්‍රමාදයෙන් පසු ආරක්ෂාව

    final auth = context.read<AuthProvider>();

    // If not signed in, go to home | ලොග් නොවූ නම් ගෙදර (home) තිරයට
    if (!auth.isSignedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    // Route based on role | භූමිකාව අනුව මාර්ගය තෝරයි
    switch (auth.role) {
      case UserRole.organizer:
        Navigator.of(context)
            .pushReplacementNamed('/organizer_dashboard');
        break;
      case UserRole.admin:
        Navigator.of(context).pushReplacementNamed('/admin_panel');
        break;
      default:
        Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    // Always dispose animation controllers to avoid memory leaks
    // මතකය නාස්ති වීම වළක්වීමට ජීව්‍රිතකරණ පාලකය සෑම විටම dispose කළ යුතුය
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Full-screen diagonal gradient background | සම්පූර්ණ තිරය ආවරණය කරන අනුක්‍රමිත (gradient) පසුබිම
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B3A5C),
              Color(0xFF0A3D62),
            ],
          ),
        ),
        child: Center(
          // AnimatedBuilder rebuilds when _controller ticks
          // _controller ටික් කරන සෑම විටම AnimatedBuilder නැවත ගොඩනංවයි
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo container with glowing accent ring
                // ගොළු ආලෝකය (glow) සහිත ලාංජනය (logo) කොටුව
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_activity_rounded,
                    size: 80,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 28),
                // App name | යෙදුමේ නම
                const Text(
                  'MyTickets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                // App domain | වෙබ් ලිපිනය (domain)
                const Text(
                  'www.mytickets.lk',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 15,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Tagline | හඳුන්වාදීමේ වාක්‍ය ඛණ්ඩය
                const Text(
                  'Your Ultimate Event Experience',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 60),
                // Loading indicator | දත්ත පූරණ සලකුණ
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
