import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/session_manager.dart';

/// Handles token refresh and expiration detection.
/// Integrates with SessionManager for global logout.
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  final _storage = const FlutterSecureStorage();
  final _sessionManager = SessionManager();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  Timer? _expiryTimer;
  DateTime? _tokenExpiry;

  /// Whether token is currently valid.
  bool get isTokenValid {
    if (_tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  /// Time remaining until token expires.
  Duration? get timeUntilExpiry {
    if (_tokenExpiry == null) return null;
    final remaining = _tokenExpiry!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Store token with expiry information.
  Future<void> saveToken({
    required String accessToken,
    String? refreshToken,
    int? expiresIn, // seconds
    DateTime? expiresAt,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);

    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }

    // Calculate expiry
    if (expiresAt != null) {
      _tokenExpiry = expiresAt;
    } else if (expiresIn != null) {
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    } else {
      // Default: 1 hour if not specified
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
    }

    await _storage.write(
      key: _tokenExpiryKey,
      value: _tokenExpiry!.toIso8601String(),
    );

    _scheduleExpiryCheck();

    if (kDebugMode) {
      debugPrint('[TokenManager] Token saved, expires at: $_tokenExpiry');
    }
  }

  /// Get current access token.
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    // Check if expired
    await _loadExpiry();
    if (!isTokenValid) {
      if (kDebugMode) {
        debugPrint('[TokenManager] Token expired, attempting refresh');
      }
      // Try to refresh
      final refreshed = await attemptRefresh();
      if (!refreshed) {
        return null;
      }
      return await _storage.read(key: _tokenKey);
    }

    return token;
  }

  /// Get refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Load token expiry from storage.
  Future<void> _loadExpiry() async {
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr != null) {
      try {
        _tokenExpiry = DateTime.parse(expiryStr);
      } catch (_) {
        _tokenExpiry = null;
      }
    }
  }

  /// Schedule a check before token expires.
  void _scheduleExpiryCheck() {
    _expiryTimer?.cancel();

    if (_tokenExpiry == null) return;

    final timeUntil = timeUntilExpiry;
    if (timeUntil == null || timeUntil.isNegative) return;

    // Schedule refresh 5 minutes before expiry
    final refreshTime = timeUntil - const Duration(minutes: 5);

    if (refreshTime.isNegative) {
      // Less than 5 minutes left, try refresh now
      attemptRefresh();
      return;
    }

    _expiryTimer = Timer(refreshTime, () {
      attemptRefresh();
    });

    if (kDebugMode) {
      debugPrint(
        '[TokenManager] Scheduled refresh in ${refreshTime.inMinutes} minutes',
      );
    }
  }

  /// Attempt to refresh the token.
  /// Returns true if successful, false otherwise.
  Future<bool> attemptRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      _sessionManager.notifySessionExpired(
        reason: 'Sesi Anda telah berakhir. Silakan login kembali.',
      );
      return false;
    }

    // Note: Actual refresh API call should be implemented here
    // For now, we just notify session expired
    // In production, this would call the refresh endpoint

    if (kDebugMode) {
      debugPrint(
        '[TokenManager] Token refresh not implemented, session expired',
      );
    }

    _sessionManager.notifySessionExpired(
      reason: 'Sesi Anda telah berakhir. Silakan login kembali.',
    );
    return false;
  }

  /// Clear all tokens (on logout).
  Future<void> clearTokens() async {
    _expiryTimer?.cancel();
    _tokenExpiry = null;

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);

    if (kDebugMode) {
      debugPrint('[TokenManager] Tokens cleared');
    }
  }

  /// Handle 401 response from API.
  void handleUnauthorized() {
    _sessionManager.notifySessionExpired(
      reason: 'Sesi Anda tidak valid. Silakan login kembali.',
    );
  }

  /// Dispose resources.
  void dispose() {
    _expiryTimer?.cancel();
  }
}
