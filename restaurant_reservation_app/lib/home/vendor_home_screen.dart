import 'package:flutter/material.dart';
import 'package:restaurant_reservation_app/bookings/booked_tables_screen.dart';
import 'package:restaurant_reservation_app/categories/add_category_screen.dart';
import 'package:restaurant_reservation_app/restaurants/add_restaurant_screen.dart';
import 'package:restaurant_reservation_app/widgets/action_card.dart';

class VendorHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vendor Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          children: [
            ActionCard(
              title: 'Add Category',
              icon: Icons.category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddCategoryScreen()),
                );
              },
            ),
            ActionCard(
              title: 'Add Restaurant',
              icon: Icons.restaurant,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddRestaurantScreen()),
                );
              },
            ),
            ActionCard(
              title: 'View Bookings',
              icon: Icons.event_seat,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookedTablesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
