import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/booking/book_table_screen.dart';
import 'package:customer_app/providers/booking_provider.dart';
import 'package:customer_app/restaurant_details/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;

  final String customerId = FirebaseAuth.instance.currentUser!.uid;

  RestaurantDetailsScreen(this.restaurantId);

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  int? selectedTable;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookingProvider>().listenToReservationsForRestaurant(
        widget.restaurantId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Restaurant Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final map = data.data() as Map<String, dynamic>;

          Uint8List imageBytes = base64Decode(map['imageBase64']);
          final int tablesCount = map['tablesCount'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.memory(
                imageBytes,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  map['name'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(map['description']),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Select Table',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: tablesCount,
                  itemBuilder: (context, index) {
                    final tableNumber = index + 1;

                    final isBooked = bookingProvider.isTimeBooked(
                      tableNumber: tableNumber,
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
                ),
              ),

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
                                customerId:
                                    FirebaseAuth.instance.currentUser!.uid,
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
