//widgets/restaurant_card.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantCard extends StatelessWidget {
  final QueryDocumentSnapshot restaurant;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onViewBookings;

  const RestaurantCard({
    required this.restaurant,
    required this.onTap,
    required this.onLongPress,
    required this.onViewBookings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            /// IMAGE — هي اللي تمسك الارتفاع
            Expanded(
              child: Image.memory(
                base64Decode(restaurant['imageBase64']),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            /// CONTENT — ارتفاعه طبيعي
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant['categoryName'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onViewBookings,
                      child: const Text(
                        'View Bookings',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
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
