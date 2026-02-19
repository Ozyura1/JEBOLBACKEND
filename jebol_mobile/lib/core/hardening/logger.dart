import 'package:flutter/foundation.dart';

/// Centralized logger that respects environment settings.
/// In production, all logging is disabled.
class AppLogger {
  static bool _enabled = kDebugMode;

  /// Enable or disable logging.
  static void setEnabled(bool enabled) {
    _enabled = enabled && kDebugMode; // Never enable in release builds
  }

  /// Log info message.
  static void info(String tag, String message) {
    if (_enabled) {
      debugPrint('[$tag] $message');
    }
  }

  /// Log warning message.
  static void warning(String tag, String message) {
    if (_enabled) {
      debugPrint('⚠️ [$tag] $message');
    }
  }

  /// Log error message.
  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (_enabled) {
      debugPrint('❌ [$tag] $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log network request.
  static void network(
    String method,
    String url, {
    int? statusCode,
    String? body,
  }) {
    if (_enabled) {
      debugPrint('🌐 [$method] $url');
      if (statusCode != null) {
        debugPrint('   Status: $statusCode');
      }
      if (body != null && body.length < 500) {
        debugPrint('   Body: $body');
      }
    }
  }

  /// Log navigation.
  static void navigation(String from, String to) {
    if (_enabled) {
      debugPrint('🧭 Navigation: $from → $to');
    }
  }

  /// Log user action.
  static void action(String action, [Map<String, dynamic>? params]) {
    if (_enabled) {
      debugPrint('👆 Action: $action');
      if (params != null) {
        debugPrint('   Params: $params');
      }
    }
  }
}

/// Debug utilities that are only active in debug mode.
class DebugUtils {
  /// Check if running in debug mode.
  static bool get isDebugMode => kDebugMode;

  /// Execute only in debug mode.
  static void debugOnly(VoidCallback action) {
    if (kDebugMode) {
      action();
    }
  }

  /// Assert in debug mode only.
  static void debugAssert(bool condition, [String? message]) {
    assert(condition, message);
  }
}
