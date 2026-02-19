import 'package:flutter/foundation.dart';
import '../core/auth/auth_exception.dart';
import '../models/user.dart';
import '../core/constants/roles.dart';
import '../services/api_service.dart';

/// Authentication state managed by ChangeNotifier.
///
/// This service is the SINGLE SOURCE OF TRUTH for auth state in the app.
/// - Handles login, logout, and session restore
/// - Validates tokens against backend (backend is source of truth)
/// - Parses roles strictly (crashes on unknown roles)
/// - Separates auth logic from UI completely
///
/// PENTING: Tidak ada "mengira-ngira". Semua flow tunduk ke API contract.
class AuthService with ChangeNotifier {
  User? _currentUser;
  final ApiService _apiService;

  /// Internal auth status for service operations
  AuthStatus _state = AuthStatus.initial;
  String? _errorMessage;

  AuthService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  // ============================================================
  // GETTERS
  // ============================================================

  User? get currentUser => _currentUser;
  AuthStatus get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _currentUser != null && _currentUser!.token != null;
  bool get isLoading => _state == AuthStatus.loading;
  bool get isAuthenticated => _state == AuthStatus.authenticated;
  bool get isUnauthenticated => _state == AuthStatus.unauthenticated;
  bool get hasError => _state == AuthStatus.error;

  UserRole? get currentRole => _currentUser?.role;

  // ============================================================
  // INITIALIZATION - Session Restore
  // ============================================================

  /// Initialize auth state by checking stored token and validating with backend.
  ///
  /// This MUST be called on app startup. It will:
  /// 1. Check for stored token
  /// 2. Validate token by calling getMe() on backend
  /// 3. If valid, restore user session
  /// 4. If invalid/expired, try to refresh token
  /// 5. If refresh fails, clear session
  ///
  /// Backend adalah source of truth. Tidak ada "mengira-ngira".
  Future<void> initialize() async {
    _setState(AuthStatus.loading);
    _errorMessage = null;

    try {
      final hasToken = await _apiService.hasToken();
      if (!hasToken) {
        // No token stored - user needs to login
        _currentUser = null;
        _setState(AuthStatus.unauthenticated);
        return;
      }

      // Validate token by calling getMe()
      final result = await _apiService.getMe();

      if (result['success'] == true && result['data'] != null) {
        // Token valid - restore session
        final userData = _extractUserData(result['data']);
        if (userData != null) {
          final token = await _apiService.getAccessToken();
          userData['token'] = token;

          final user = User.fromJson(userData);

          // Validate user is active
          if (!user.isActive) {
            await _clearSession();
            _errorMessage = 'Akun Anda tidak aktif. Hubungi administrator.';
            _setState(AuthStatus.error);
            return;
          }

          _currentUser = user;
          _setState(AuthStatus.authenticated);
          return;
        }
      }

      // Token invalid or getMe failed - clear session
      await _clearSession();
      _setState(AuthStatus.unauthenticated);
    } on AuthException catch (e) {
      // Known auth error (e.g., unknown role)
      await _clearSession();
      _errorMessage = e.message;
      _setState(AuthStatus.error);
    } catch (e) {
      // Unexpected error - clear session to be safe
      debugPrint('AUTH INIT ERROR: $e');
      await _clearSession();
      _errorMessage = 'Terjadi kesalahan saat memulihkan sesi.';
      _setState(AuthStatus.error);
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  /// Login with username and password.
  ///
  /// Returns true if login successful, false otherwise.
  /// On failure, check [errorMessage] for details.
  ///
  /// Only these roles can login:
  /// - SUPER_ADMIN
  /// - ADMIN_KTP
  /// - ADMIN_IKD
  /// - ADMIN_PERKAWINAN
  /// - RT
  ///
  /// PUBLIC users use app without login.
  Future<bool> login(String username, String password) async {
    _setState(AuthStatus.loading);
    _errorMessage = null;

    try {
      final result = await _apiService.login(username, password);
      debugPrint('LOGIN RESULT: $result');

      if (result['success'] != true) {
        // Login failed - extract error message
        _errorMessage = result['message'] ?? 'Username atau password salah.';
        _setState(AuthStatus.unauthenticated);
        return false;
      }

      // Extract user data from response
      final userData = _extractUserData(result['data']);
      if (userData == null) {
        _errorMessage = 'Respons server tidak valid.';
        _setState(AuthStatus.unauthenticated);
        return false;
      }

      // Extract token
      final data = result['data'] as Map;
      final token = data['access_token'] as String? ?? data['token'] as String?;
      if (token == null) {
        _errorMessage = 'Token tidak ditemukan dalam respons.';
        _setState(AuthStatus.unauthenticated);
        return false;
      }

      userData['token'] = token;

      // Parse user - will throw AuthException on unknown role
      final user = User.fromJson(userData);
      debugPrint(
        'Parsed user: id=${user.id}, username=${user.username}, role=${user.role}, isActive=${user.isActive}',
      );

      // Validate user is active
      if (!user.isActive) {
        await _clearSession();
        _errorMessage = 'Akun Anda tidak aktif. Hubungi administrator.';
        _setState(AuthStatus.error);
        return false;
      }

      // Success!
      _currentUser = user;
      _setState(AuthStatus.authenticated);
      return true;
    } on AuthException catch (e) {
      // Known auth error (e.g., unknown role from backend)
      debugPrint('LOGIN AUTH EXCEPTION: $e');
      await _clearSession();
      _errorMessage = e.message;
      _setState(AuthStatus.error);
      return false;
    } catch (e) {
      // Unexpected error
      debugPrint('LOGIN EXCEPTION: $e');
      _errorMessage = 'Terjadi kesalahan saat login. Coba lagi.';
      _setState(AuthStatus.error);
      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  /// Logout current user.
  ///
  /// Calls backend to invalidate token, then clears local session.
  Future<void> logout() async {
    _setState(AuthStatus.loading);
    _errorMessage = null;

    try {
      // Call backend to invalidate token (ignore errors)
      await _apiService.logout();
    } catch (e) {
      debugPrint('LOGOUT ERROR (ignored): $e');
    }

    await _clearSession();
    _setState(AuthStatus.unauthenticated);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _setState(AuthStatus newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    await _apiService.clearTokens();
  }

  /// Expose stored token for callers that need it (e.g., AuthProvider)
  Future<String?> getStoredToken() async {
    return await _apiService.getAccessToken();
  }

  /// Extract user data from API response.
  /// Handles both nested { user: {...} } and flat user data.
  Map<String, dynamic>? _extractUserData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // Check if user is nested under 'user' key
      if (data.containsKey('user') && data['user'] is Map) {
        return Map<String, dynamic>.from(data['user'] as Map);
      }
      // User data is at root level
      if (data.containsKey('id') || data.containsKey('username')) {
        return Map<String, dynamic>.from(data);
      }
    }

    return null;
  }
}

/// Internal authentication status used by AuthService.
enum AuthStatus {
  /// Initial state before initialization
  initial,

  /// Loading state during async operations
  loading,

  /// User is authenticated with valid token
  authenticated,

  /// User is not authenticated (no token or public user)
  unauthenticated,

  /// Authentication error occurred
  error,
}
