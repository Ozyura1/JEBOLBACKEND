import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../services/api_service.dart';
import '../services/secure_storage.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  final ApiService _apiService;
  final SecureStorage _storage;

  AuthService([ApiService? apiService, SecureStorage? storage])
    : _apiService = apiService ?? ApiService(),
      _storage = storage ?? const SecureStorage();

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null && _currentUser!.token != null;

  Future<void> initialize() async {
    final token = await _storage.read(key: 'api_token');
    if (token != null) {
      // Assuming we can get user from token, but for now, set public if no token
      // In real app, validate token and get user info
      _currentUser = User(
        id: '1',
        username: 'user',
        role: UserRole.public, // Default, should fetch from API
        token: token,
      );
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final result = await _apiService.login(username, password);
      print('LOGIN RESULT: $result');
      if (result['success'] == true) {
        // Defensive parsing and debug logs
        final dynamic rawData = result['data'];
        print('LOGIN raw data type: ${rawData.runtimeType}');
        if (rawData is Map) {
          final data = Map<String, dynamic>.from(rawData);
          final userRaw = data['user'];
          print('LOGIN userRaw: $userRaw');
          if (userRaw is Map) {
            final userData = Map<String, dynamic>.from(userRaw);
            final token =
                data['access_token'] as String? ?? data['token'] as String?;
            print('LOGIN token: $token');
            if (token != null) {
              userData['token'] = token; // pastikan token masuk ke userData
              print('LOGIN userData after token assign: $userData');
              final user = User.fromJson(userData);
              print(
                'Parsed user: id=${user.id}, username=${user.username}, role=${user.role}, token=${user.token}',
              );
              // Only allow login for allowed roles
              if ([
                UserRole.superAdmin,
                UserRole.admin1,
                UserRole.admin2,
                UserRole.admin3,
                UserRole.rt,
              ].contains(user.role)) {
                _currentUser = user;
                await _storage.write(key: 'api_token', value: token);
                notifyListeners();
                return true;
              } else {
                // Block Public User and others
                await logout();
                return false;
              }
            }
          } else {
            print('LOGIN ERROR: data[user] is not a Map');
          }
        } else {
          print('LOGIN ERROR: data is not Map');
        }
      }
      return false;
    } catch (e) {
      print('LOGIN EXCEPTION: $e');
      return false;
    }
  }

  Future<void> logout() async {
    if (_currentUser?.token != null) {
      try {
        await _apiService.logout();
      } catch (e) {
        // Ignore logout errors
      }
    }
    _currentUser = null;
    await _storage.delete(key: 'api_token');
    await _storage.delete(key: 'refresh_token');
    notifyListeners();
  }

  void setPublicUser() {
    _currentUser = User(
      id: 'public',
      username: 'public',
      role: UserRole.public,
    );
    notifyListeners();
  }
}
