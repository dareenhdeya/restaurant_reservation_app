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
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // دالة تسجيل الخروج
  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // بعد تسجيل الخروج ممكن ترجع للصفحة الرئيسية للولوج (LoginScreen)
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      // في حالة وجود خطأ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Hello ya drdr"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
