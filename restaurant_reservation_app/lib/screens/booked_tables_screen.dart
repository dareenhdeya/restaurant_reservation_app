import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/booking_service.dart';
import 'restaurant_bookings_screen.dart';

class BookedTablesScreen extends StatelessWidget {
  final bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booked Tables')),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingService.getVendorRestaurants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final restaurants = snapshot.data!.docs;

          if (restaurants.isEmpty) {
            return Center(child: Text('No restaurants added yet'));
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];

              return Card(
                margin: EdgeInsets.all(12),
                child: ListTile(
                  title: Text(restaurant['name']),
                  subtitle: Text(restaurant['categoryName']),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantBookingsScreen(
                          restaurantId: restaurant.id,
                          restaurantName: restaurant['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
