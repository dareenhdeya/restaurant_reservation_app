import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getReservationsForRestaurant(String restaurantId) {
    return _db
        .collection('reservations')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots();
  }
}
