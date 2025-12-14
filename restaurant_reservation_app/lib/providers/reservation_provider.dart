import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservationProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> _reservations = [];
  List<QueryDocumentSnapshot> get reservations => _reservations;

  void listenToRestaurantReservations(String restaurantId) {
    _firestore
        .collection('reservations')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .listen((snapshot) {
      _reservations = snapshot.docs;
      notifyListeners();
    });
  }
}
