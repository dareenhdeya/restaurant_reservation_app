// home/vendor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../screens/add_category_screen.dart';
import '../screens/add_restaurant_screen.dart';
import '../screens/restaurant_details_screen.dart';
import '../screens/restaurant_bookings_screen.dart';
import '../widgets/action_card.dart';
import '../widgets/restaurant_card.dart';

class VendorHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            /// ACTION CARDS
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      title: 'Categories',
                      icon: Icons.category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCategoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      title: 'Add Restaurant',
                      icon: Icons.restaurant,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddRestaurantScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            /// EMPTY STATE
            if (provider.restaurants.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No restaurants yet')),
              )
            else
              /// RESTAURANTS GRID
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final restaurant = provider.restaurants[index];

                  return RestaurantCard(
                    restaurant: restaurant,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RestaurantDetailsScreen(restaurant: restaurant),
                        ),
                      );
                    },
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddRestaurantScreen(restaurant: restaurant),
                        ),
                      );
                    },
                    onViewBookings: () {
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
                  );
                }, childCount: provider.restaurants.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
