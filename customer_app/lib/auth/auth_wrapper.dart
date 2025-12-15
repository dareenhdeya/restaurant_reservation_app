<<<<<<< HEAD
import 'package:customer_app/auth/screens/auth_screen.dart';
=======
>>>>>>> 650f96ddd2ce8618db165768af430662fa47edd5
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import '../home/home_screen.dart';
<<<<<<< HEAD
=======
import 'screens/login_screen.dart';
>>>>>>> 650f96ddd2ce8618db165768af430662fa47edd5

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // المستخدم مسجل دخول
        if (state is AuthAuthenticated) {
          return HomeScreen();
        }

        // المستخدم مش مسجل
        if (state is AuthUnauthenticated) {
<<<<<<< HEAD
          return AuthScreen();
=======
          return LoginScreen();
>>>>>>> 650f96ddd2ce8618db165768af430662fa47edd5
        }

        // loading / initial
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
