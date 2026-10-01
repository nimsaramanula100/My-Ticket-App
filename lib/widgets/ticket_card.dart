// lib/widgets/ticket_card.dart
// ─────────────────────────────────────────────────────────────────────────────
// TicketCard | ප්‍රවේශපත්‍ර පත (Ticket Display Card Widget)
// Reusable white-themed card widget representing a purchasable ticket item.
// මිලදී ගත හැකි ප්‍රවේශපත්‍රයක් නිරූපණය කරන නැවත භාවිත කළ හැකි සුදු පැහැති තේමා කාඩ්පතකි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket
      ticket; // Ticket/Event data model | ප්‍රවේශපත්‍ර / සිදුවීම් දත්ත ආකෘතිය

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Format date and time for visual display | දෘශ්‍ය ප්‍රදර්ශනය සඳහා දිනය සහ වේලාව හැඩගන්වයි
    final formattedDate = DateFormat('dd MMM yyyy').format(ticket.eventDate);
    final formattedTime = DateFormat('hh:mm a').format(ticket.eventDate);

    // Check if seats are running low (50 or less) to trigger warning color
    // ඉතිරිව ඇති ආසන ගණන අඩු දැයි (50 හෝ ඊට අඩු) පරීක්ෂා කරයි (අනතුරු ඇඟවීම් වර්ණ සක්‍රීය කිරීමට)
    final lowSeats = ticket.availableSeats <= 50;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Banner Image & Overlay Badges | බැනර් රූපය සහ ලේබල ────────────────
            Stack(
              children: [
                // 1. Image cover loader | 1. රූපය පූරණය
                if (ticket.imageUrl.isNotEmpty)
                  Image.network(
                    ticket.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.blueGrey.shade100,
                      child: const Icon(Icons.broken_image,
                          size: 48, color: Colors.blueGrey),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.indigo.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.event, size: 64, color: Colors.white70),
                    ),
                  ),
                // 2. Category Badge | 2. ප්‍රවර්ග ලේබලය
                if (ticket.category.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ticket.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // 3. Available Seats Warning Badge | 3. ඉතිරිව ඇති ආසන ප්‍රමාණයේ අනතුරු ඇඟවීමේ ලේබලය
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      // Red if low, green if safe | අඩු නම් රතුද, ආරක්ෂිත නම් කොළද වේ
                      color: lowSeats
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ticket.availableSeats} LEFT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ─── Details section | විස්තර අංශය ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title | සිදුවීමේ නම
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location Row | ස්ථානය පෙන්වන පේළිය
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ticket.venue,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Date and Time Row | දිනය සහ වේලාව පෙන්වන පේළිය
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        '$formattedDate at $formattedTime',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Price and Details action row | මිල සහ විස්තර බොත්තම් තීරුව
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${ticket.currency} ${ticket.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ],
                      ),
                      // Details navigation indicator | විස්තර බැලීමේ බොත්තම
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.indigo.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
