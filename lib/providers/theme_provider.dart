// lib/providers/theme_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// ThemeProvider | තේමා කළමනාකරණය
// Manages the application's global theme state (Light or Dark).
// යෙදුමේ ගෝලීය තේමා තත්වය (ආලෝකමත් හෝ අඳුරු) කළමනාකරණය කරයි.
// Uses SharedPreferences to persist the user's choice across restarts.
// යෙදුම නැවත ආරම්භ කිරීමේදී තෝරාගත් තේමාව ආරක්ෂා කර ගැනීමට SharedPreferences භාවිත කරයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'theme_mode_is_dark';

  // Default to dark theme if no preference is saved.
  // සුරැකි මනාපයක් නොමැති නම් අඳුරු තේමාව පෙරනිමි ලෙස තබයි.
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // ─── Load saved theme from SharedPreferences | සුරකින ලද තේමාව ලබා ගැනීම ────────
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Use dark mode as the default fallback
    final isDark = prefs.getBool(_themePrefKey) ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // ─── Toggle theme and save | තේමාව වෙනස් කර සුරැකීම ─────────────────────────────
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, isDark);
  }
}
