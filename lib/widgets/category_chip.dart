// lib/widgets/category_chip.dart
// ─────────────────────────────────────────────────────────────────────────────
// CategoryChip | ප්‍රවර්ග චිප් එක (Category Selection Chip)
// Reusable widget representing an event category selection item.
// සිදුවීම් ප්‍රවර්ග තේරීම සඳහා නැවත භාවිත කළ හැකි කුඩා අතුරුමුහුණත් බොත්තමකි.
// Uses an AnimatedContainer to smoothly transition colors and shadows on state changes.
// තේරීම් තත්වය වෙනස් වන විට වර්ණ සහ සෙවනැලි සුමටව වෙනස් කිරීමට AnimatedContainer එකක් යොදා ගනී.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import '../theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  // ─── Fields / Properties | ගුණාංග ──────────────────────────────────────────
  final String label;        // Category text (e.g., 'Concert') | ප්‍රවර්ගයේ නම (e.g., 'Concert')
  final bool isSelected;     // Active selection status indicator | තෝරාගෙන ඇති තත්වය දක්වන සලකුණ
  final VoidCallback onTap;  // Function executed on click event | ක්ලික් කළ විට ධාවනය වන ශ්‍රිතය

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  // ─── build: Construct UI | අතුරුමුහුණත ගොඩනැගීම ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Dynamic color selection matching category label | ප්‍රවර්ග නම අනුව අදාළ වර්ණය ලබා ගනී
    final catColor = AppColors.categoryColor(label);

    return GestureDetector(
      onTap: onTap, // Call passed handler | ලබා දී ඇති ක්‍රියාව ධාවනය කරවයි
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Transition duration | වර්ණ වෙනස් වීමේ ප්‍රවේගය
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Active state gets category color, inactive gets surfaceVariant
          // තෝරාගෙන ඇති විට ප්‍රවර්ග වර්ණයද, නැති විට surfaceVariant වර්ණයද යොදයි
          color: isSelected ? catColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? catColor : const Color(0xFF243B55),
            width: 1.5,
          ),
          // Glow shadow effect when item is active | සක්‍රීයව ඇති විට ලබා දෙන සෙවනැලි ආචරණය
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic icon matching category label | ප්‍රවර්ගයට ගැළපෙන අයිකනය
            Icon(
              _categoryIcon(label),
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            // Category text display label | ප්‍රවර්ග නම පෙන්වන පෙළ
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── _categoryIcon: Map categories to Icons | ප්‍රවර්ග වලට අයිකන ගැලපීම ─────────
  // Returns appropriate IconData based on the category string.
  // ප්‍රවර්ගයේ නම (String) අනුව ඊට ගැළපෙන IconData එකක් තෝරා ලබා දෙයි.
  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'concert':
        return Icons.music_note_rounded;
      case 'sports':
        return Icons.sports_cricket_rounded;
      case 'theater':
        return Icons.theater_comedy_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'festival':
        return Icons.celebration_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}
