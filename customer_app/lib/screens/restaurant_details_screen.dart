import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/screens/book_table_screen.dart';
import 'package:customer_app/providers/booking_provider.dart';
import 'package:customer_app/widgets/table_widget.dart';
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
  DateTime? selectedDate;

  String get formattedDate => selectedDate == null
      ? 'Select Date'
      : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}';

  bool tableFullyBooked(int tableNumber) {
    final timeSlots = [
      '10:00 AM',
      '12:00 PM',
      '02:00 PM',
      '04:00 PM',
      '06:00 PM',
    ];

    return timeSlots.every(
      (time) => context.read<BookingProvider>().isTimeBooked(
        tableNumber: tableNumber,
        timeSlot: time,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Restaurant Detailsssssssssssss')),
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
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        selectedTable = null; // إعادة تعيين اختيار الترابيزة
                      });

                      // استمع للحجوزات حسب التاريخ المحدد
                      context
                          .read<BookingProvider>()
                          .listenToReservationsForRestaurant(
                            widget.restaurantId,
                            formattedDate,
                          );
                    }
                  },
                  child: Text(formattedDate),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Select Table',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: selectedDate == null
                    ? Center(
                        child: Text(
                          'Please select a date first',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: tablesCount,
                        itemBuilder: (context, index) {
                          final tableNumber = index + 1;

                          // final isBooked = bookingProvider.isTimeBooked(
                          //   tableNumber: tableNumber,
                          // );

                          return TableWidget(
                            tableNumber: tableNumber,
                            isSelected: selectedTable == tableNumber,

                            isBooked: tableFullyBooked(tableNumber),

                            onTap: () {
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
                  onPressed: selectedTable == null || selectedDate == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookTableScreen(
                                restaurantId: widget.restaurantId,
                                tableNumber: selectedTable!,
                                customerId: widget.customerId,
                                date: formattedDate,
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
