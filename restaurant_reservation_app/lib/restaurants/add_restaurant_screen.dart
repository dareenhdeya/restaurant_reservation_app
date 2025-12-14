import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/location_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_service.dart';

class AddRestaurantScreen extends StatefulWidget {
  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tablesController = TextEditingController();
  final _seatsController = TextEditingController();

  String? selectedCategoryId;
  String? selectedCategoryName;

  final restaurantService = RestaurantService();

  File? _image;
  double? lat;
  double? lng;

  final ImagePicker _picker = ImagePicker();

  // ---------- Image ----------
  Future<void> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  // ---------- Location ----------
  Future<void> getLocation() async {
    try {
      final position = await LocationHelper.getCurrentLocation();
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null || lat == null || lng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Complete all fields')));
      return;
    }

    try {
      // Encode image
      final imageBase64 = await restaurantService.encodeImage(_image!);

      // Save data
      await restaurantService.addRestaurant(
        name: _nameController.text,
        description: _descController.text,
        imageBase64: imageBase64,
        categoryId: selectedCategoryId!,
        categoryName: selectedCategoryName!,
        tables: int.parse(_tablesController.text),
        seats: int.parse(_seatsController.text),
        lat: lat!,
        lng: lng!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Restaurant added successfully')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Restaurant')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              Center(
                child: GestureDetector(
                  onTap: () => showImagePicker(),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all()),
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 40)
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Restaurant Name'),
                validator: (v) => v!.isEmpty ? 'Enter restaurant name' : null,
              ),

              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final categories = snapshot.data!.docs;

                  return DropdownButtonFormField(
                    // initialValue: selectedCategoryId,
                    value: selectedCategoryId,
                    hint: Text('Select Category'),
                    items: categories.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final doc = categories.firstWhere((e) => e.id == value);
                      setState(() {
                        selectedCategoryId = value.toString();
                        selectedCategoryName = doc['name'];
                      });
                    },
                    validator: (v) => v == null ? 'Select category' : null,
                  );
                },
              ),

              TextFormField(
                controller: _tablesController,
                decoration: InputDecoration(labelText: 'Number of Tables'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter tables count' : null,
              ),

              TextFormField(
                controller: _seatsController,
                decoration: InputDecoration(
                  labelText: 'Seats per Table (max 6)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 6) {
                    return 'Seats must be 1–6';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: getLocation,
                icon: Icon(Icons.location_on),
                label: Text(lat == null ? 'Get Location' : 'Location Added'),
              ),

              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: saveRestaurant,
                  child: Text('Save Restaurant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Bottom Sheet ----------
  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
