import 'package:flutter/material.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _service = RestaurantService();

  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> addRestaurant({
    required String name,
    required String description,
    required String imageBase64,
    required String categoryId,
    required String categoryName,
    required int tables,
    required int seats,
    required double lat,
    required double lng,
  }) async {
    _loading = true;
    notifyListeners();

    await _service.addRestaurant(
      name: name,
      description: description,
      imageBase64: imageBase64,
      categoryId: categoryId,
      categoryName: categoryName,
      tables: tables,
      seats: seats,
      lat: lat,
      lng: lng,
    );

    _loading = false;
    notifyListeners();
  }
}
