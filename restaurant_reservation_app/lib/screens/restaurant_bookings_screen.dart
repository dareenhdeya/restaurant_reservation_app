// screens/restaurant_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/booking_service.dart';

class RestaurantBookingsScreen extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  RestaurantBookingsScreen({
    required this.restaurantId,
    required this.restaurantName,
  });

  final bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurantName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingService.getRestaurantBookings(restaurantId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return Center(child: Text('No bookings yet'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                margin: EdgeInsets.all(12),
                child: ListTile(
                  leading: Icon(Icons.event_seat),
                  title: Text(
                    'Table ${booking['tableNumber']} - ${booking['timeSlot']}',
                  ),
                  subtitle: Text(
                    'Seats: ${booking['seats']} | Date: ${booking['date']}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
