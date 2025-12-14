import 'package:customer_app/auth/cubit/auth_cubit.dart';
import 'package:customer_app/auth/cubit/auth_state.dart';
import 'package:customer_app/auth/screens/login_screen.dart';
import 'package:customer_app/home/home_screen.dart';
import 'package:customer_app/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/auth/models/customer_model.dart';
import 'package:customer_app/auth/services/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  String email = '';
  String password = '';
  String name = '';
  String phone = '';
  String confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          // إنشاء Customer object بعد التسجيل
          final customer = Customer(
            uid: state.user.uid,
            email: email,
            name: name,
            phone: phone,
          );

          await _firestoreService.createCustomer(customer);

          final user = state.user;
          await user.updateDisplayName(name);
          await user.reload();
          print('Updated displayName: ${user.displayName}');

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (_) => HomeScreen()),
          // );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthCubit>().register(email, password);
                    }
                  },
                  child: Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
