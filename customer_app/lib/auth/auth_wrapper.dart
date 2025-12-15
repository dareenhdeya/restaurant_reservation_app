import 'package:customer_app/auth/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import '../home/home_screen.dart';

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
          return AuthScreen();
        }

        // loading / initial
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
