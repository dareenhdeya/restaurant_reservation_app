import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  final _db = FirebaseFirestore.instance;

  Future<QuerySnapshot> searchRestaurant(String name) {
    return _db
        .collection('restaurants')
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThanOrEqualTo: '$name\uf8ff')
        .get();
  }
}
