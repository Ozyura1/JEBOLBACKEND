import 'package:flutter/foundation.dart';

/// Non-sensitive audit logger for government-grade application.
///
/// IMPORTANT:
/// - Does NOT log personal data (NIK, names, addresses)
/// - Does NOT log tokens or credentials
/// - ONLY logs navigation and action events
/// - Can be toggled via environment
class AuditLogger {
  static final AuditLogger _instance = AuditLogger._internal();
  factory AuditLogger() => _instance;
  AuditLogger._internal();

  /// Enable/disable logging based on environment.
  /// Set to false for production audit security.
  bool _enabled = !kReleaseMode;

  final List<AuditLogEntry> _logs = [];

  /// Maximum log entries to keep in memory.
  static const int _maxEntries = 500;

  /// Enable or disable logging.
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Log a navigation event.
  void logNavigation({required String from, required String to}) {
    _addEntry(
      AuditLogEntry(
        type: AuditLogType.navigation,
        action: 'navigate',
        details: 'From: $from → To: $to',
      ),
    );
  }

  /// Log a submission action (without personal data).
  void logSubmission({
    required String module,
    required String action,
    String? submissionId,
  }) {
    _addEntry(
      AuditLogEntry(
        type: AuditLogType.submission,
        action: action,
        details:
            'Module: $module${submissionId != null ? ', ID: $submissionId' : ''}',
      ),
    );
  }

  /// Log an authentication event.
  void logAuth({required String action, String? userId}) {
    _addEntry(
      AuditLogEntry(
        type: AuditLogType.auth,
        action: action,
        details: userId != null ? 'User ID: $userId' : null,
      ),
    );
  }

  /// Log a status change action.
  void logStatusChange({
    required String module,
    required String submissionId,
    required String fromStatus,
    required String toStatus,
  }) {
    _addEntry(
      AuditLogEntry(
        type: AuditLogType.statusChange,
        action: 'status_change',
        details: 'Module: $module, ID: $submissionId, $fromStatus → $toStatus',
      ),
    );
  }

  /// Log an error event (non-sensitive).
  void logError({required String source, required String errorType}) {
    _addEntry(
      AuditLogEntry(
        type: AuditLogType.error,
        action: 'error',
        details: 'Source: $source, Type: $errorType',
      ),
    );
  }

  /// Log a network event.
  void logNetwork({
    required String method,
    required String path,
    required int statusCode,
  }) {
    _addEntry(
      AuditLogEntry(
        type: AuditLogType.network,
        action: method.toUpperCase(),
        details: 'Path: $path, Status: $statusCode',
      ),
    );
  }

  void _addEntry(AuditLogEntry entry) {
    if (!_enabled) return;

    _logs.add(entry);

    // Trim old entries if exceeded limit.
    if (_logs.length > _maxEntries) {
      _logs.removeRange(0, _logs.length - _maxEntries);
    }

    // Debug print in development only.
    if (kDebugMode) {
      debugPrint(
        '[AUDIT] ${entry.type.name.toUpperCase()}: ${entry.action} - ${entry.details ?? 'N/A'}',
      );
    }
  }

  /// Get recent log entries (for audit display, non-sensitive).
  List<AuditLogEntry> getRecentLogs({int limit = 50}) {
    final start = _logs.length > limit ? _logs.length - limit : 0;
    return _logs.sublist(start).reversed.toList();
  }

  /// Clear all logs.
  void clear() {
    _logs.clear();
  }
}

enum AuditLogType { navigation, submission, auth, statusChange, error, network }

class AuditLogEntry {
  final DateTime timestamp;
  final AuditLogType type;
  final String action;
  final String? details;

  AuditLogEntry({required this.type, required this.action, this.details})
    : timestamp = DateTime.now();

  @override
  String toString() {
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    return '[$time] ${type.name.toUpperCase()}: $action${details != null ? ' - $details' : ''}';
  }
}
