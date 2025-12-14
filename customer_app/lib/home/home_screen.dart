// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: Text('Register')),
//       body:Text("hallo ya drdr")

//    );
//   }
//   }

import 'package:customer_app/auth/screens/login_screen.dart';
import 'package:customer_app/auth/services/auth_service.dart';
import 'package:customer_app/categories/category_restaurants_screen.dart';
import 'package:customer_app/home/category_card.dart';
import 'package:customer_app/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  final _categoryService = CategoryService();
  final _auth = AuthService();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurant...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CategoryRestaurantsScreen(search: value),
                    ),
                  );
                }
              },
            ),
          ),

          // 🍽 Categories
          Expanded(
            child: StreamBuilder(
              stream: _categoryService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!.docs;

                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      categoryId: categories[index].id,
                      name: categories[index]['name'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   // دالة تسجيل الخروج
//   void _signOut(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       // بعد تسجيل الخروج ممكن ترجع للصفحة الرئيسية للولوج (LoginScreen)
//       Navigator.of(
//         context,
//       ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
//     } catch (e) {
//       // في حالة وجود خطأ
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("Hello ya drdr"),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _signOut(context),
//               child: const Text('Log Out'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
