import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot restaurant;

  const RestaurantDetailsScreen({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final image = base64Decode(restaurant['imageBase64']);
    final int tablesCount = restaurant['tablesCount'];

    return Scaffold(
      appBar: AppBar(title: Text(restaurant['name'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Image.memory(
              image,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// INFO
                  Text(
                    restaurant['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(restaurant['description']),
                  const SizedBox(height: 12),
                  Text('Category: ${restaurant['categoryName']}'),
                  const SizedBox(height: 8),
                  Text('Tables: $tablesCount'),
                  Text('Seats per table: ${restaurant['seatsPerTable']}'),

                  const SizedBox(height: 24),

                  /// TABLES TITLE
                  const Text(
                    'Tables Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  /// BOOKINGS STREAM
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('restaurants')
                        .doc(restaurant.id)
                        .collection('bookings')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      /// booked table numbers
                      final bookedTables = snapshot.hasData
                          ? snapshot.data!.docs
                                .map((e) => e['tableNumber'] as int)
                                .toSet()
                          : <int>{};

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tablesCount,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemBuilder: (context, index) {
                          final tableNumber = index + 1;
                          final isBooked = bookedTables.contains(tableNumber);

                          return Container(
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.red.shade400
                                  : Colors.green.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.table_restaurant,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Table $tableNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isBooked ? 'Booked' : 'Available',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
