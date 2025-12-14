import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/location_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/restaurant_service.dart';

class AddRestaurantScreen extends StatefulWidget {
  final QueryDocumentSnapshot? restaurant;
  AddRestaurantScreen({this.restaurant});
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
  bool locationUP = false;
  bool locationButtonEnabled = true;

  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.restaurant != null;

  static const String addNewCategoryValue = 'add_new';

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final r = widget.restaurant!;
      _nameController.text = r['name'];
      _descController.text = r['description'];
      _tablesController.text = r['tablesCount'].toString();
      _seatsController.text = r['seatsPerTable'].toString();
      selectedCategoryId = r['categoryId'];
      selectedCategoryName = r['categoryName'];

      lat = r['location']['lat'];
      lng = r['location']['lng'];
    }
  }

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

        locationUP = true;
        locationButtonEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: !isEdit ? Text('Location Added') : Text('Location updated'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    // if (!isEdit && (_image == null || lat == null || lng == null)) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Complete all fields')));
    //   return;
    // }
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please add location')));
      return;
    }

    try {
      String imageBase64;

      if (_image != null) {
        imageBase64 = await restaurantService.encodeImage(_image!);
      } else {
        imageBase64 = widget.restaurant!['imageBase64'];
      }

      if (isEdit) {
        await restaurantService.updateRestaurant(
          id: widget.restaurant!.id,
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
      } else {
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
      }

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
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Restaurant' : 'Add Restaurant'),
      ),
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
                  onTap: showImagePicker,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : isEdit
                        ? Image.memory(
                            base64Decode(widget.restaurant!['imageBase64']),
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.camera_alt, size: 40),
                  ),
                ),

                // child: GestureDetector(
                //   onTap: () => showImagePicker(),
                //   child: Container(
                //     height: 160,
                //     width: double.infinity,
                //     decoration: BoxDecoration(border: Border.all()),
                //     child: _image == null
                //         ? Icon(Icons.camera_alt, size: 40)
                //         : Image.file(_image!, fit: BoxFit.cover),
                //   ),
                // ),
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
                    initialValue: selectedCategoryId,
                    hint: Text('Select Category'),
                    items: [
                      ...categories.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }),
                      DropdownMenuItem(
                        value: addNewCategoryValue,
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Add new category'),
                          ],
                        ),
                      ),
                    ],

                    // onChanged: (value) {
                    //   final doc = categories.firstWhere((e) => e.id == value);
                    //   setState(() {
                    //     selectedCategoryId = value.toString();
                    //     selectedCategoryName = doc['name'];
                    //   });
                    // },
                    onChanged: (value) async {
                      if (value == addNewCategoryValue) {
                        final result = await showAddCategoryDialog();
                        if (result != null) {
                          setState(() {
                            selectedCategoryId = result['id'];
                            selectedCategoryName = result['name'];
                          });
                        }
                        return;
                      }

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
                onPressed: locationButtonEnabled ? getLocation : null,
                icon: Icon(Icons.location_on),
                label: Text(
                  lat == null
                      ? 'Get Location'
                      : !isEdit
                      ? 'Location Added'
                      : !locationUP
                      ? 'Update Location'
                      : 'Location Updated',
                ),
              ),

              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: saveRestaurant,
                  child: Text(isEdit ? 'Update Restaurant' : 'Save Restaurant'),
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

  Future<Map<String, String>?> showAddCategoryDialog() async {
    final controller = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final doc = await FirebaseFirestore.instance
                  .collection('categories')
                  .add({
                    'name': name,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

              Navigator.pop(context, {'id': doc.id, 'name': name});
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
