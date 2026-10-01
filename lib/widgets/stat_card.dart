// lib/widgets/stat_card.dart
// ─────────────────────────────────────────────────────────────────────────────
// StatCard | සංඛ්‍යාලේඛන පත (Dashboard Statistic Widget)
// Reusable KPI card designed for dashboard metrics (e.g. revenue, ticket sales count).
// උපකරණ පුවරුවේ (Dashboard) දත්ත පෙන්වීමට යොදා ගන්නා නැවත භාවිත කළ හැකි කාඩ්පත් අංගයකි.
// Features a dynamic icon box, a truncated label, and prominent stat values.
// එහි හැඩගන්වන ලද අයිකනයක්, කෙටි මාතෘකාවක් සහ කැපී පෙනෙන සංඛ්‍යා අගයන් අඩංගු වේ.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import '../theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  // ─── Properties / Fields | ගුණාංග ──────────────────────────────────────────
  final String title;   // KPI title/label (e.g. 'Total Sales') | දර්ශකයේ නම (e.g. 'Total Sales')
  final String value;   // Textual value to display (e.g. 'Rs. 45,000') | ප්‍රදර්ශනය කළ යුතු සංඛ්‍යාත්මක අගය
  final IconData icon;  // Associated visual indicator icon | ඊට අදාළ අයිකනය
  final Color? color;   // Color used to tint the icon box | අයිකනය හැඩගැන්වීමට භාවිතා කරන වර්ණය

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  // ─── build: Construct UI | අතුරුමුහුණත ගොඩනැගීම ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Falls back to organizer theme accent if no explicit color is set
    // කිසිදු වර්ණයක් සකසා නොමැති නම් සංවිධායක පොදු වර්ණය (organizerAccent) යොදා ගනී
    final themeColor = color ?? AppColors.organizerAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243B55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header row: Icon box + Title label | 1. ඉහළ පෙළ: අයිකන කොටුව සහ මාතෘකාව
          Row(
            children: [
              // Icon container with 15% opacity background tint
              // අයිකනයට ගැළපෙන වර්ණයෙන් 15% ක විනිවිදභාවයක් සහිත පසුබිම් කොටුවක් සාදයි
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: themeColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Truncate title if it exceeds horizontal space
              // මාතෘකාව දිග වැඩි නම් එය තිරයට ගැළපෙන සේ කපා දමයි (ellipsis)
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2. Large numeric/stat value | 2. කැපී පෙනෙන විශාල සංඛ්‍යාත්මක අගය
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
