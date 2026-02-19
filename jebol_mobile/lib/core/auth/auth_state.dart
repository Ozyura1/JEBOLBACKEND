import '../../models/user_model.dart';

class AuthState {
  final String? token;
  final User? user;
  final bool isInitializing;

  const AuthState({
    required this.token,
    required this.user,
    this.isInitializing = false,
  });

  bool get isAuthenticated => token != null && user != null;

  factory AuthState.unauthenticated() {
    return const AuthState(
      token: null,
      user: null,
      isInitializing: false,
    );
  }

  factory AuthState.initializing() {
    return const AuthState(
      token: null,
      user: null,
      isInitializing: true,
    );
  }
}
