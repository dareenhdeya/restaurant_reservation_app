import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit(this.authService) : super(AuthInitial()) {
    _authSubscription = authService.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    print('=======================Auth state changed: $user =================/n'); // هنا هتشوف null لو logout أو delete
    if (user == null) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(user));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await authService.login(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      await authService.register(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await authService.logout();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
