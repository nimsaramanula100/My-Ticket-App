// lib/widgets/category_chip.dart
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import '../theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(label);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? catColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? catColor : const Color(0xFF243B55),
            width: 1.5,
          ),
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
            Icon(
              _categoryIcon(label),
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
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
