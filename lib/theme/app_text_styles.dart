// lib/theme/app_text_styles.dart
// ─────────────────────────────────────────────────────────────────────────────
// AppTextStyles | යෙදුමේ අකුරු රටා (Typography)
// Centralized typography configurations using Google Fonts (Poppins & Outfit).
// Google Fonts (Poppins සහ Outfit) භාවිතයෙන් සකසන ලද යෙදුමේ පොදු අකුරු රටා එකතුව.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

class AppTextStyles {
  // ─── Display / Hero Text: Large prominent typography | ප්‍රදර්ශන / විශාල සිරස්තල ───
  
  // displayLarge: Hero headers and screen main headings
  // displayLarge: ප්‍රධාන තිරයන්හී සිරස්තල සහ විශාල මාතෘකා සඳහා
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // displayMedium: Section main headers or key highlights
  // displayMedium: ප්‍රධාන කොටස් වල උප-සිරස්තල හෝ විශේෂ උද්දීපනයන් සඳහා
  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // displaySmall: Screen headings or prominent labels
  // displaySmall: මධ්‍යම ප්‍රමාණයේ තිර සිරස්තල සඳහා
  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ─── Headlines: Standard category and block headers | මධ්‍යම සිරස්තල ───────────

  // headlineLarge: Section headings inside screens
  // headlineLarge: තිරයන් තුළ ඇති විවිධ කොටස් වල සිරස්තල
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // headlineMedium: Form labels and card titles
  // headlineMedium: ආකෘති පත්‍ර (Form) ලේබල සහ කාඩ්පත් මාතෘකා
  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // headlineSmall: Small section headers
  // headlineSmall: කුඩා කොටස් වල මාතෘකා සඳහා
  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ─── Body: Regular paragraphs and information texts | ඡේද සහ විස්තර අකුරු ───────

  // bodyLarge: Primary details, details text on ticket descriptions
  // bodyLarge: ප්‍රධාන විස්තර සහ ප්‍රවේශපත්‍ර විස්තරාත්මක ඡේද සඳහා
  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5, // Line height formatting | පේළි අතර පරතරය
  );

  // bodyMedium: Standard body texts and secondary details
  // bodyMedium: සාමාන්‍ය ඡේද අකුරු සහ ද්විතීයික විස්තර සඳහා
  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // bodySmall: Captions, helper guidelines, and timestamps
  // bodySmall: උපමාතෘකා, මඟපෙන්වීම් සහ කාල සටහන් විස්තර සඳහා
  static TextStyle get bodySmall => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // ─── Labels: Form inputs, buttons, and helper terms | ලේබල සහ බොත්තම් අකුරු ───

  // labelLarge: Standard button actions and form headers
  // labelLarge: ප්‍රධාන බොත්තම් වල ක්‍රියාත්මක පෙළ සහ ලේබල සඳහා
  static TextStyle get labelLarge => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  // labelMedium: Medium details in lists
  // labelMedium: ලැයිස්තු වල මධ්‍යම ප්‍රමාණයේ විස්තර ලේබල සඳහා
  static TextStyle get labelMedium => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // labelSmall: Meta details, category chips
  // labelSmall: මෙටා විස්තර සහ කුඩා ලේබල සඳහා
  static TextStyle get labelSmall => GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  // ─── Special Styles: Specialized widgets and values | විශේෂිත අකුරු රටා ───────

  // price: Currency values displaying ticket cost
  // price: ප්‍රවේශපත්‍ර මිල අගයන් ප්‍රදර්ශනය කිරීම සඳහා
  static TextStyle get price => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    letterSpacing: -0.3,
  );

  // priceSmall: Secondary smaller price values
  // priceSmall: කුඩා මිල ගණන් ප්‍රදර්ශනය කිරීම සඳහා
  static TextStyle get priceSmall => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
  );

  // buttonText: Bold white labels inside custom buttons
  // buttonText: බොත්තම් තුළ ඇති සුදු පැහැති කැපී පෙනෙන අකුරු රටාව
  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  // category: Spaced uppercase text on categories
  // category: කාණ්ඩ නාමයන් ප්‍රදර්ශනය කිරීමේ අකුරු රටාව
  static TextStyle get category => GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  // badge: Status pill badges (PAID, PENDING)
  // badge: තත්ව සලකුණු (PAID, PENDING ආදිය) සඳහා
  static TextStyle get badge => GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // tabLabel: Navigation tabs labels
  // tabLabel: ටැබ්ස් (Tabs) සංචාලන ලේබල සඳහා
  static TextStyle get tabLabel => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // sectionTitle: Header styling for list views sections
  // sectionTitle: ලැයිස්තු අංශයන්හි මාතෘකා සඳහා
  static TextStyle get sectionTitle => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // cardTitle: Event name inside custom cards
  // cardTitle: කාඩ්පත් තුළ ඇති සිදුවීම් නාම සඳහා
  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // cardSubtitle: Event venue or city text inside cards
  // cardSubtitle: කාඩ්පත් තුළ ඇති ස්ථානය හෝ නගරය පිළිබඳ විස්තරය
  static TextStyle get cardSubtitle => GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
