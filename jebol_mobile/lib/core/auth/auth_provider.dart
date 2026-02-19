import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  AuthState _state = AuthState.initializing();


  AuthProvider([AuthService? service])
    : _authService = service ?? AuthService();

  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;
  User? get user => _state.user;
  String? get errorMessage => _authService.errorMessage;

  // Compatibility getters used across the app
  User? get currentUser => user;
  bool get isLoggedIn => isAuthenticated;

  /// Restore session from stored token. Must be called on app start.
  Future<void> restoreSession() async {
  try {
    final storedToken = await _authService.getStoredToken();

    if (storedToken == null) {
      _state = AuthState.unauthenticated();
      notifyListeners();
      return;
    }

    await _authService.initialize();
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      await logout();
      return;
    }

    _state = AuthState(
      token: storedToken,
      user: currentUser,
    );
    notifyListeners();
  } catch (e) {
    await logout();
  }
}

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      final token = await _authService.getStoredToken();
      final currentUser = _authService.currentUser;
      _state = AuthState(token: token, user: currentUser);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Ensure session is valid by re-validating token with backend.
  /// Returns true if session is still valid, false otherwise.
  Future<bool> ensureValidSession() async {
    final storedToken = await _authService.getStoredToken();
    if (storedToken == null) {
      await logout();
      return false;
    }

    try {
      await _authService.initialize();
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        await logout();
        return false;
      }
      _state = AuthState(token: storedToken, user: currentUser);
      notifyListeners();
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _state = AuthState.unauthenticated();
    notifyListeners();
  }
}
