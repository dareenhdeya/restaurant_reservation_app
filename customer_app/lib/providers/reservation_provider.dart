// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../services/reservation_service.dart';

// class ReservationProvider with ChangeNotifier {
//   final ReservationService _service = ReservationService();

//   List<QueryDocumentSnapshot> _reservations = [];
//   List<QueryDocumentSnapshot> get reservations => _reservations;

//   bool _loading = false;
//   bool get isLoading => _loading;

//   void listenToReservations(String restaurantId) {
//     _loading = true;
//     notifyListeners();

//     _service.getReservationsForRestaurant(restaurantId).listen((snapshot) {
//       _reservations = snapshot.docs;
//       _loading = false;
//       notifyListeners();
//     });
//   }

//   bool isTableBooked(int tableNumber) {
//     return _reservations.any(
//       (r) => r['tableNumber'] == tableNumber,
//     );
//   }

//   Future<void> bookTable({
//     required String restaurantId,
//     required int tableNumber,
//     required String customerId,
//     required String timeSlot,
//   }) async {
//     await _service.bookTable(
//       restaurantId: restaurantId,
//       tableNumber: tableNumber,
//       customerId: customerId,
//       timeSlot: timeSlot,
//     );
//   }
// }
