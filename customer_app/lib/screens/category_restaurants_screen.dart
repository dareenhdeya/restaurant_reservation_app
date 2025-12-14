// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:customer_app/restaurant_details/restaurant_details_screen.dart';
// import 'package:customer_app/services/restaurant_service.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:typed_data';

// class CategoryRestaurantsScreen extends StatelessWidget {
//   final String? categoryId;
//   final String? search;

//   CategoryRestaurantsScreen({this.categoryId, this.search});

//   @override
//   Widget build(BuildContext context) {
//     Query query = FirebaseFirestore.instance.collection('restaurants');

//     if (categoryId != null) {
//       query = query.where('categoryId', isEqualTo: categoryId);
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text('Restaurants')),
//       body: StreamBuilder(
//         stream: search == null ? query.snapshots() : null,
//         // future: search != null
//         //     ? RestaurantService().searchRestaurant(search!)
//         //     : null,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return Center(child: Text('No restaurants found'));
//           }

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index];
//               return ListTile(
//                 leading: Builder(
//                   builder: (context) {
//                     final map = data.data() as Map<String, dynamic>;

//                     if (!map.containsKey('imageBase64') ||
//                         map['imageBase64'] == null) {
//                       return Container(
//                         width: 50,
//                         height: 50,
//                         color: Colors.grey[300],
//                         child: Icon(Icons.image),
//                       );
//                     }

//                     Uint8List bytes = base64Decode(map['imageBase64']);

//                     return Image.memory(
//                       bytes,
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                     );
//                   },
//                 ),

//                 title: Text(data['name']),
//                 subtitle: Text(data['description']),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => RestaurantDetailsScreen(data.id),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:customer_app/providers/restaurant_provider.dart';
import 'package:customer_app/screens/restaurant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class CategoryRestaurantsScreen extends StatefulWidget {
  final String? categoryId;
  final String? search;

  const CategoryRestaurantsScreen({this.categoryId, this.search});

  @override
  State<CategoryRestaurantsScreen> createState() =>
      _CategoryRestaurantsScreenState();
}

class _CategoryRestaurantsScreenState extends State<CategoryRestaurantsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RestaurantProvider>().listenToRestaurants(
        categoryId: widget.categoryId,
        search: widget.search,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Restaurants')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.restaurants.isEmpty
          ? Center(child: Text('No restaurants found'))
          : ListView.builder(
              itemCount: provider.restaurants.length,
              itemBuilder: (context, index) {
                final data = provider.restaurants[index];
                final map = data.data() as Map<String, dynamic>;

                Widget imageWidget = Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: Icon(Icons.image),
                );

                if (map['imageBase64'] != null) {
                  imageWidget = Image.memory(
                    base64Decode(map['imageBase64']),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                }

                return ListTile(
                  leading: imageWidget,
                  title: Text(map['name']),
                  subtitle: Text(map['description']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantDetailsScreen(data.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
