// lib/theme/color_palette.dart
import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand Primary ─────────────────────────────────────────
  static const Color primary = Color(0xFF0D1B2A);        // Deep navy
  static const Color primaryLight = Color(0xFF1B2E45);
  static const Color primaryVariant = Color(0xFF0A3D62);

  // ─── User-side Accent (Electric Orange) ────────────────────
  static const Color accent = Color(0xFFFF6B35);         // Vibrant orange
  static const Color accentLight = Color(0xFFFF8F65);
  static const Color accentDark = Color(0xFFE84D1C);

  // ─── Organizer-side Accent (Electric Violet) ───────────────
  static const Color organizerAccent = Color(0xFF7C3AED);
  static const Color organizerLight = Color(0xFF9B5CF6);
  static const Color organizerDark = Color(0xFF5B21B6);

  // ─── Surfaces ──────────────────────────────────────────────
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1B2E45);
  static const Color surfaceVariant = Color(0xFF243B55);
  static const Color cardColor = Color(0xFF1E3347);

  // ─── Light Mode ────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF0F4F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ─── Text ──────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0C4D8);
  static const Color textMuted = Color(0xFF6B8BAE);
  static const Color textDark = Color(0xFF0D1B2A);

  // ─── Status ────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF3C6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

 
  static const LinearGradient organizerGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E3347), Color(0xFF243B55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xDD0D1B2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Category Colors ───────────────────────────────────────
  static const Color concertColor = Color(0xFFFF6B35);
  static const Color sportsColor = Color(0xFF10B981);
  static const Color theaterColor = Color(0xFF8B5CF6);
  static const Color movieColor = Color(0xFF3B82F6);
  static const Color festivalColor = Color(0xFFF59E0B);
  static const Color otherColor = Color(0xFF6B7280);

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'concert': return concertColor;
      case 'sports': return sportsColor;
      case 'theater': return theaterColor;
      case 'movie': return movieColor;
      case 'festival': return festivalColor;
      default: return otherColor;
    }
  }
}
