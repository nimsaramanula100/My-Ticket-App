// lib/widgets/event_card.dart
// ─────────────────────────────────────────────────────────────────────────────
// EventCard | සිදුවීම් පත (Event Card Widget)
// Reusable card widget to display event details in a list or carousel.
// සිදුවීම් විස්තර ලැයිස්තුවක හෝ කැරොසලයක පෙන්වීමට භාවිත වන නැවත භාවිත කළ හැකි කාඩ්පත් අංගයකි.
// Supports both a horizontal/featured look and a compact list look.
// විශේෂිත (Featured) පතක සහ සාමාන්‍ය (Regular) ලැයිස්තු පතක ආකාර දෙකටම සහාය දක්වයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../theme/color_palette.dart';
import '../theme/app_text_styles.dart';

class EventCard extends StatelessWidget {
  final Ticket event; // Ticket/Event data model | සිදුවීම් දත්ත ආකෘතිය
  final VoidCallback
      onTap; // Click action callback | ක්ලික් කළ විට ක්‍රියාත්මක වන ශ්‍රිතය
  final bool
      isFeatured; // Toggle between hero and list layout | විශේෂිත සහ සාමාන්‍ය පිරිසැලසුම් මාරුකරණ සලකුණ

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    // Routes to correct layout based on isFeatured status
    // isFeatured තත්වය අනුව ගැළපෙන පිරිසැලසුම තෝරා ගොඩනඟයි
    return isFeatured
        ? _FeaturedCard(event: event, onTap: onTap)
        : _RegularCard(event: event, onTap: onTap);
  }
}

// ─── _FeaturedCard: Large horizontal featured card | විශාල විශේෂිත සිදුවීම් පත ──────
class _FeaturedCard extends StatelessWidget {
  final Ticket event;
  final VoidCallback onTap;
  const _FeaturedCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Format date as "Day-of-week, Day Month" | දිනය "සඳුදා, 12 ජූලි" ලෙස සකසයි
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
              // 1. Background image with cache placeholder | 1. පසුබිම් රූපය සහ පූරණ රූපය
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
              // 2. Gradient overlay to make text readable | 2. පෙළ කියවීමට පහසුවන අඳුරු පසුබිම් අනුක්‍රමණය
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.heroGradient),
                ),
              ),
              // 3. Featured Badge | 3. විශේෂිත (Featured) සලකුණ
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
              // 4. Sold Out Badge | 4. විකිණී අවසන් (Sold Out) සලකුණ
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
              // 5. Details container at the bottom | 5. පහළ ඇති විස්තර තීරුව
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category tag | ප්‍රවර්ග ලේබලය
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
                      // Event name text | සිදුවීමේ නම
                      Text(event.eventName,
                          style: AppTextStyles.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      // Date and location line | දිනය සහ ස්ථාන විස්තර
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
                      // Price and "Book Now" action row | මිල සහ වෙන්කරගැනීමේ බොත්තම
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${event.currency} ${NumberFormat('#,###').format(event.price)}',
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

  // Helper widget to display when image is loading or fails
  // රූප පූරණය වන විට හෝ අසාර්ථක වූ විට පෙන්වන ආදර්ශ රූපය
  Widget _imagePlaceholder(Color color) {
    return Container(
      color: color.withValues(alpha: 0.3),
      child: Center(
        child: Icon(_categoryIcon(event.category), size: 48, color: color),
      ),
    );
  }
}

// ─── _RegularCard: Compact list style card | සංයුක්ත සාමාන්‍ය ලැයිස්තු පත ────────────
class _RegularCard extends StatelessWidget {
  final Ticket event;
  final VoidCallback onTap;
  const _RegularCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Format date with year as "Day, dd Month yyyy" | දිනය වසර සමඟ සකසයි
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
            // Left block: Small image | වම් පස කුඩා රූපය
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
            // Right block: Info column | දකුණු පස විස්තර තීරුව
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Category tag | ප්‍රවර්ග ලේබලය
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
                        // Sold out tag | විකිණී අවසන් සලකුණ
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
                    // Event title | සිදුවීමේ නම
                    Text(event.eventName,
                        style: AppTextStyles.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    // Date display | දිනය පෙන්වීම
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(dateStr, style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Location and price row | ස්ථානය සහ මිල තීරුව
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
                          '${event.currency} ${NumberFormat('#,###').format(event.price)}',
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

  // Helper thumbnail placeholder when image is missing
  // පින්තූරය නොමැතිවිට පෙන්වන කුඩා ආදර්ශ පින්තූර කොටුව
  Widget _thumb(Color color) {
    return Container(
      color: color.withValues(alpha: 0.25),
      child: Center(
          child: Icon(_categoryIcon(event.category), size: 32, color: color)),
    );
  }
}

// ─── _categoryIcon: Map category to Icons | ප්‍රවර්ගයට අයිකන ගැලපීම ─────────────────
// Shared static helper function to resolve icons for cards.
// කාඩ්පත් සඳහා ප්‍රවර්ග නම අනුව ගැළපෙන අයිකනය ලබා දෙන පොදු ශ්‍රිතයකි.
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
