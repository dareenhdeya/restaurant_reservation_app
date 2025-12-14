import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getReservations({
    required String restaurantId,
    required String date,
  }) {
    return _db
        .collection('reservations')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('date', isEqualTo: date)
        .snapshots();
  }

  Future<void> bookTable({
    required String restaurantId,
    required int tableNumber,
    required int seats,
    required String date,
    required String timeSlot,
  }) async {
    await _db.collection('reservations').add({
      'restaurantId': restaurantId,
      'tableNumber': tableNumber,
      'seats': seats,
      'date': date,
      'timeSlot': timeSlot,
      'customerId': FirebaseAuth.instance.currentUser!.uid,
    });
  }
}
