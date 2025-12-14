import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/booking/book_table_screen.dart';
import 'package:customer_app/restaurant_details/table_widget.dart';
import 'package:customer_app/services/reservation_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;

  RestaurantDetailsScreen(this.restaurantId);

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  int? selectedTable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurant Details')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (!data.data()!.containsKey('imageBase64')) {
            return Center(
              child: Icon(
                Icons.image_not_supported,
                size: 100,
                color: Colors.grey,
              ),
            );
          }
          Uint8List imageBytes = base64Decode(data['imageBase64']);
          final int tablesCount = data['tablesCount'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Image
              Image.memory(
                imageBytes,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  data['name'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(data['description']),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Select Table',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 🪑 Tables (Figure 3)
              Expanded(
                child: StreamBuilder(
                  stream: ReservationService().getReservationsForRestaurant(
                    widget.restaurantId,
                  ),
                  builder: (context, snapshot) {
                    final reservations = snapshot.hasData
                        ? snapshot.data!.docs
                        : [];

                    return GridView.builder(
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: tablesCount,
                      itemBuilder: (context, index) {
                        final tableNumber = index + 1;

                        final isBooked = reservations.any(
                          (r) => r['tableNumber'] == tableNumber,
                        );

                        return TableWidget(
                          tableNumber: tableNumber,
                          isSelected: selectedTable == tableNumber,
                          isBooked: isBooked,
                          onTap: isBooked
                              ? null
                              : () {
                                  setState(() {
                                    selectedTable = tableNumber;
                                  });
                                },
                        );
                      },
                    );
                  },
                ),
              ),

              // ➡ Continue
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: selectedTable == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookTableScreen(
                                restaurantId: widget.restaurantId,
                                tableNumber: selectedTable!,
                              ),
                            ),
                          );
                        },
                  child: Text('Continue'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
