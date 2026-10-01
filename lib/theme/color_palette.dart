// lib/theme/color_palette.dart
// ─────────────────────────────────────────────────────────────────────────────
// AppColors | යෙදුමේ වර්ණ පද්ධතිය (Color Palette)
// Centralized color definitions and gradients applied across both user and organizer apps.
// පරිශීලක සහ සංවිධායක යෙදුම් වල භාවිත වන සියලුම පොදු වර්ණ, අනුක්‍රමණ (Gradients) සහ කාණ්ඩ වර්ණ සැකසුම් ගොනුව.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand Primary: Deep navy tones | ප්‍රධාන සන්නාම වර්ණ (තද නිල් වර්ණ) ───────
  static const Color primary = Color(0xFF0D1B2A);        // Deep navy | තද නිල්
  static const Color primaryLight = Color(0xFF1B2E45);   // Lighter navy | මදක් ලා නිල්
  static const Color primaryVariant = Color(0xFF0A3D62); // Variant navy | වෙනස් නිල් පැහැයක්

  // ─── User-side Accent (Electric Orange) | පරිශීලක අංශයේ කැපීපෙනෙන වර්ණ (තැඹිලි) ──
  static const Color accent = Color(0xFFFF6B35);         // Vibrant orange | තද තැඹිලි
  static const Color accentLight = Color(0xFFFF8F65);    // Light orange | ලා තැඹිලි
  static const Color accentDark = Color(0xFFE84D1C);     // Dark orange | තද තැඹිලි

  // ─── Organizer-side Accent (Electric Violet) | සංවිධායක අංශයේ කැපීපෙනෙන වර්ණ (දම්) ──
  static const Color organizerAccent = Color(0xFF7C3AED); // Vibrant violet | තද දම්
  static const Color organizerLight = Color(0xFF9B5CF6);  // Light violet | ලා දම්
  static const Color organizerDark = Color(0xFF5B21B6);   // Dark violet | තද දම්

  // ─── Surfaces: Backgrounds and container colors | පෘෂ්ඨීය / බහාලුම් වර්ණ ───────
  static const Color background = Color(0xFF0D1B2A);      // App background | යෙදුමේ පසුබිම් වර්ණය
  static const Color surface = Color(0xFF1B2E45);         // Standard container surface | සාමාන්‍ය බහාලුම් පෘෂ්ඨය
  static const Color surfaceVariant = Color(0xFF243B55);  // Alternative container surface | විකල්ප බහාලුම් පෘෂ්ඨය
  static const Color cardColor = Color(0xFF1E3347);       // Event card background | සිදුවීම් පත පසුබිම් වර්ණය

  // ─── Light Mode: Light themes backgrounds and surfaces | ලා පැහැති තේමා වර්ණ ─────────
  static const Color lightBackground = Color(0xFFF0F4F8); // Light mode background | ලා පසුබිම් වර්ණය
  static const Color lightSurface = Color(0xFFFFFFFF);    // Light mode surface | ලා පෘෂ්ඨ වර්ණය
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0); // Alternative container | විකල්ප බහාලුම් පෘෂ්ඨය
  static const Color lightCard = Color(0xFFFFFFFF);       // Light mode card | ලා කාඩ්පත් වර්ණය

  // ─── Text: Text readable overlays | අකුරු සඳහා වර්ණ ───────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);       // Text on primary background | ප්‍රධාන පසුබිම මත ඇති සුදු අකුරු
  static const Color onSurface = Color(0xFFFFFFFF);       // Text on surface containers | පෘෂ්ඨීය බහාලුම් මත ඇති සුදු අකුරු
  static const Color textPrimary = Color(0xFFFFFFFF);     // Bold primary headlines | ප්‍රධාන සිරස්තල අකුරු වර්ණය
  static const Color textSecondary = Color(0xFFB0C4D8);   // Secondary body/paragraphs | ද්විතීයික විස්තර අකුරු වර්ණය
  static const Color textMuted = Color(0xFF6B8BAE);       // Labels or inactive options | අක්‍රීය හෝ මැකී ගිය අකුරු වර්ණය
  
  // Light Mode Text | ලා තේමාව සඳහා අකුරු වර්ණ
  static const Color lightTextPrimary = Color(0xFF0F172A);   // Dark bold headlines | ලා පසුබිම් මත තද අකුරු
  static const Color lightTextSecondary = Color(0xFF475569); // Dark secondary body | ද්විතීයික තද අකුරු
  static const Color lightTextMuted = Color(0xFF94A3B8);     // Light mode muted | අක්‍රීය අකුරු
  
  static const Color textDark = Color(0xFF0D1B2A);        // Dark text for light surfaces | ලා පසුබිම් මත තද අකුරු වර්ණය

  // ─── Status: Notifications and alert states | තත්ව සලකුණු වර්ණ ─────────────────
  static const Color success = Color(0xFF10B981);         // Success green | සාර්ථක (කොළ)
  static const Color warning = Color(0xFFF59E0B);         // Warning amber | අනතුරු ඇඟවීම් (කහ)
  static const Color error = Color(0xFFEF4444);           // Failure/Error red | දෝෂ/අවලංගු (රතු)
  static const Color info = Color(0xFF3B82F6);            // Informational blue | තොරතුරු දැනුම්දීම් (නිල්)

  // ─── Gradients: Smooth color transitions | වර්ණ අනුක්‍රමණ (Gradients) ──────────
  
  // Primary gradient: Used in background views
  // Primary gradient: පසුබිම් දසුන් සඳහා භාවිතා කරයි
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent gradient: Highlights actions/buttons on user-side
  // Accent gradient: පරිශීලක බොත්තම් කැපී පෙනීමට භාවිතා කරයි
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF3C6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Organizer gradient: Highlights actions/buttons on organizer-side
  // Organizer gradient: සංවිධායක බොත්තම් කැපී පෙනීමට භාවිතා කරයි
  static const LinearGradient organizerGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card gradient: Applied to customizable cards
  // Card gradient: කාඩ්පත්/පත් වල පසුබිමට යොදයි
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E3347), Color(0xFF243B55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Hero gradient: Used for bottom fade-out effect on banner images
  // Hero gradient: රූපවල පහළ කොටස අඳුරු කර පෙළ කැපී පෙනීමට යොදයි
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xDD0D1B2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Category Colors: Colors linked to event categories | කාණ්ඩ වර්ණ ─────────
  static const Color concertColor = Color(0xFFFF6B35);
  static const Color sportsColor = Color(0xFF10B981);
  static const Color theaterColor = Color(0xFF8B5CF6);
  static const Color movieColor = Color(0xFF3B82F6);
  static const Color festivalColor = Color(0xFFF59E0B);
  static const Color otherColor = Color(0xFF6B7280);

  // Maps category name to designated Color profile
  // කාණ්ඩයේ නම අනුව ඊට අදාළ වර්ණය තෝරා දෙන ශ්‍රිතය (Function)
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
