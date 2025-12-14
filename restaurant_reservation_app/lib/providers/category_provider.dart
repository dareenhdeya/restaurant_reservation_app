import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> _categories = [];
  List<QueryDocumentSnapshot> get categories => _categories;

  void listenToCategories() {
    _firestore.collection('categories').snapshots().listen((snapshot) {
      _categories = snapshot.docs;
      notifyListeners();
    });
  }

  Future<void> addCategory(String name) async {
    await _firestore.collection('categories').add({
      'name': name,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }
}
