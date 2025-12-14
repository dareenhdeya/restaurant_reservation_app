import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getReservations({
    required String restaurantId,
    required String date,
  }) {
    return _firestore
        .collection('reservations')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('date', isEqualTo: date)
        .snapshots();
  }

  Stream<QuerySnapshot> getReservationsForRestaurant(String restaurantId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> bookTable({
    required String restaurantId,
    required int tableNumber,
    required int seats,
    required String date,
    required String customerId,
    required String timeSlot,
  }) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('bookings')
        .add({
          'tableNumber': tableNumber,
          'seats': seats,
          'date': date,
          'customerId': customerId,
          'timeSlot': timeSlot,
          'createdAt': Timestamp.now(),
        });
  }
}
