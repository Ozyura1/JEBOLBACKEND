import 'dart:async';
import 'package:flutter/foundation.dart';

/// Global session manager for handling authentication state.
/// Broadcasts session expiry events to trigger auto-logout across the app.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final _sessionExpiredController =
      StreamController<SessionExpiredEvent>.broadcast();
  final _networkErrorController =
      StreamController<NetworkErrorEvent>.broadcast();

  /// Stream that emits when session expires (401 response).
  Stream<SessionExpiredEvent> get onSessionExpired =>
      _sessionExpiredController.stream;

  /// Stream that emits network errors for global handling.
  Stream<NetworkErrorEvent> get onNetworkError =>
      _networkErrorController.stream;

  /// Flag to prevent multiple logout triggers.
  bool _isHandlingExpiry = false;

  /// Notify listeners that session has expired.
  /// Called by API service when 401 is received and refresh fails.
  void notifySessionExpired({String? reason}) {
    if (_isHandlingExpiry) return;
    _isHandlingExpiry = true;

    if (kDebugMode) {
      debugPrint(
        '[SessionManager] Session expired: ${reason ?? 'Unknown reason'}',
      );
    }

    _sessionExpiredController.add(
      SessionExpiredEvent(
        reason: reason ?? 'Sesi Anda telah berakhir.',
        timestamp: DateTime.now(),
      ),
    );

    // Reset flag after a short delay to allow retry
    Future.delayed(const Duration(seconds: 2), () {
      _isHandlingExpiry = false;
    });
  }

  /// Notify listeners of a network error.
  void notifyNetworkError({required NetworkErrorType type, String? message}) {
    if (kDebugMode) {
      debugPrint('[SessionManager] Network error: ${type.name} - $message');
    }

    _networkErrorController.add(
      NetworkErrorEvent(
        type: type,
        message: message ?? _defaultMessageForType(type),
        timestamp: DateTime.now(),
      ),
    );
  }

  String _defaultMessageForType(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noInternet:
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case NetworkErrorType.timeout:
        return 'Waktu koneksi habis. Silakan coba lagi.';
      case NetworkErrorType.serverError:
        return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
      case NetworkErrorType.unknown:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Reset expiry handling state.
  void reset() {
    _isHandlingExpiry = false;
  }

  /// Dispose resources.
  void dispose() {
    _sessionExpiredController.close();
    _networkErrorController.close();
  }
}

/// Event emitted when session expires.
class SessionExpiredEvent {
  final String reason;
  final DateTime timestamp;

  const SessionExpiredEvent({required this.reason, required this.timestamp});
}

/// Event emitted for network errors.
class NetworkErrorEvent {
  final NetworkErrorType type;
  final String message;
  final DateTime timestamp;

  const NetworkErrorEvent({
    required this.type,
    required this.message,
    required this.timestamp,
  });
}

/// Types of network errors.
enum NetworkErrorType { noInternet, timeout, serverError, unknown }
