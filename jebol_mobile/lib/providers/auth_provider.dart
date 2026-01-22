import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService) {
    _authService.initialize().then((_) => notifyListeners());
  }

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  void setPublicUser() {
    _authService.setPublicUser();
    notifyListeners();
  }
}
