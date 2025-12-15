import 'package:customer_app/screens/category_restaurants_screen.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String categoryId;
  final String name;

  const CategoryCard({
    required this.categoryId,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CategoryRestaurantsScreen(categoryId: categoryId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
