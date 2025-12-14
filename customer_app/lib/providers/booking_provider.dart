import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();

  List<QueryDocumentSnapshot> _reservations = [];
  List<QueryDocumentSnapshot> get reservations => _reservations;

  bool _loading = false;
  bool get isLoading => _loading;

  // 🔹 استمع للحجوزات بتاعة مطعم معين
  void listenToReservationsForRestaurant(String restaurantId) {
    _loading = true;
    notifyListeners();

    _service.getReservationsForRestaurant(restaurantId).listen((snapshot) {
      _reservations = snapshot.docs;
      _loading = false;
      notifyListeners();
    });
  }

  // 🔹 هل الوقت محجوز للـ table معين؟
  // bool isTimeBooked({required int tableNumber, required String timeSlot}) {
  //   return _reservations.any(
  //     (r) => r['tableNumber'] == tableNumber && r['timeSlot'] == timeSlot,
  //   );
  // }
  bool isTimeBooked({required int tableNumber}) {
    // return _reservations.any(
    //   (r) => r['tableNumber'] == tableNumber && r['timeSlot'] == timeSlot,
    // );
    return _reservations.any((r) => r['tableNumber'] == tableNumber);
  }

  // 🔹 عمل حجز جديد
  Future<void> bookTable({
    required String restaurantId,
    required int tableNumber,
    required int seats,
    required String date,
    required String customerId,
    required String timeSlot,
  }) async {
    await _service.bookTable(
      restaurantId: restaurantId,
      tableNumber: tableNumber,
      seats: seats,
      date: date,
      customerId: customerId,
      timeSlot: timeSlot,
    );
  }
}
