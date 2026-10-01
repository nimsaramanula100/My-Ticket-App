// lib/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../theme/color_palette.dart';
import '../theme/app_text_styles.dart';

class EventCard extends StatelessWidget {
  final Ticket event;
  final VoidCallback onTap;
  final bool isFeatured;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return isFeatured
        ? _FeaturedCard(event: event, onTap: onTap)
        : _RegularCard(event: event, onTap: onTap);
  }
}

// ─── Featured / Hero Card ────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Ticket event;
  final VoidCallback onTap;
  const _FeaturedCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, dd MMM').format(event.eventDate);
    final catColor = AppColors.categoryColor(event.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image
              SizedBox(
                height: 200,
                width: double.infinity,
                child: event.eventImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: event.eventImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imagePlaceholder(catColor),
                        errorWidget: (_, __, ___) =>
                            _imagePlaceholder(catColor),
                      )
                    : _imagePlaceholder(catColor),
              ),
              // Gradient overlay
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.heroGradient),
                ),
              ),
              // Featured badge
              if (event.isFeatured)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('⭐ FEATURED', style: AppTextStyles.badge),
                  ),
                ),
              // Sold out overlay
              if (event.isSoldOut)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('SOLD OUT', style: AppTextStyles.badge),
                  ),
                ),
              // Content at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.category.toUpperCase(),
                          style: AppTextStyles.badge,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(event.eventName,
                          style: AppTextStyles.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(dateStr, style: AppTextStyles.bodySmall),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(event.city,
                                style: AppTextStyles.bodySmall,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rs. ${NumberFormat('#,###').format(event.price)}',
                            style: AppTextStyles.priceSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Book Now',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textDark,
                                  fontSize: 11,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(Color color) {
    return Container(
      color: color.withValues(alpha: 0.3),
      child: Center(
        child: Icon(_categoryIcon(event.category), size: 48, color: color),
      ),
    );
  }
}

// ─── Regular List Card ───────────────────────────────────────
class _RegularCard extends StatelessWidget {
  final Ticket event;
  final VoidCallback onTap;
  const _RegularCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(event.eventDate);
    final catColor = AppColors.categoryColor(event.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF243B55), width: 1),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: event.eventImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: event.eventImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _thumb(catColor),
                        errorWidget: (_, __, ___) => _thumb(catColor),
                      )
                    : _thumb(catColor),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(event.category.toUpperCase(),
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: catColor)),
                        ),
                        if (event.isSoldOut) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('SOLD OUT',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.error)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(event.eventName,
                        style: AppTextStyles.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(dateStr, style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(event.city, style: AppTextStyles.bodySmall),
                          ],
                        ),
                        Text(
                          'Rs. ${NumberFormat('#,###').format(event.price)}',
                          style:
                              AppTextStyles.priceSmall.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(Color color) {
    return Container(
      color: color.withValues(alpha: 0.25),
      child: Center(
          child: Icon(_categoryIcon(event.category), size: 32, color: color)),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
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
