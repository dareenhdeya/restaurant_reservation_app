import 'package:customer_app/auth/screens/login_screen.dart';
import 'package:customer_app/auth/services/auth_service.dart';
import 'package:customer_app/home/home_screen.dart';
import 'package:customer_app/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/auth/models/customer_model.dart';
import 'package:customer_app/auth/services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  String email = '';
  String password = '';
  String name = '';
  String phone = '';
  String confirmPassword = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: Validators.name,
                onChanged: (v) => name = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: Validators.email,
                onChanged: (v) => email = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                onChanged: (v) => phone = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: Validators.password,
                onChanged: (v) => password = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (v) {
                  if (v != password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onChanged: (v) => confirmPassword = v,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : _register,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = await _authService.register(
        email: email,
        password: password,
      );

      if (user != null) {
        // إنشاء Customer object
        final customer = Customer(
          uid: user.uid,
          email: email,
          name: name,
          phone: phone,
        );

        // تخزينه في Firestore
        await _firestoreService.createCustomer(customer);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }
}
