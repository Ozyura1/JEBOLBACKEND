import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Connectivity status enum.
enum ConnectivityStatus {
  online,
  offline,
  poor, // High latency or intermittent
}

/// Service to monitor network connectivity.
/// Provides real-time status updates without requiring third-party packages.
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  ConnectivityStatus _status = ConnectivityStatus.online;
  Timer? _checkTimer;

  /// Current connectivity status.
  ConnectivityStatus get status => _status;

  /// Alias for status (for compatibility).
  ConnectivityStatus get currentStatus => _status;

  /// Whether device is online.
  bool get isOnline => _status == ConnectivityStatus.online;

  /// Whether device is offline.
  bool get isOffline => _status == ConnectivityStatus.offline;

  /// Whether connection is poor.
  bool get isPoorConnection => _status == ConnectivityStatus.poor;

  /// Stream controller for status changes.
  final _statusController = StreamController<ConnectivityStatus>.broadcast();

  /// Stream of connectivity status changes.
  Stream<ConnectivityStatus> get onStatusChange => _statusController.stream;

  /// Alias for onStatusChange (for compatibility).
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Start monitoring connectivity.
  void startMonitoring() {
    _startPeriodicCheck();
  }

  /// Force immediate connectivity check.
  Future<ConnectivityStatus> checkNow() async {
    return await checkConnectivity();
  }

  /// Check connectivity by pinging a reliable endpoint.
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Try to lookup a reliable DNS (Google's DNS)
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('DNS lookup timeout'),
      );

      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // If latency > 3 seconds, consider it poor connection
        if (stopwatch.elapsedMilliseconds > 3000) {
          _updateStatus(ConnectivityStatus.poor);
          return ConnectivityStatus.poor;
        }

        _updateStatus(ConnectivityStatus.online);
        return ConnectivityStatus.online;
      }
    } on SocketException catch (_) {
      _updateStatus(ConnectivityStatus.offline);
      return ConnectivityStatus.offline;
    } on TimeoutException catch (_) {
      _updateStatus(ConnectivityStatus.poor);
      return ConnectivityStatus.poor;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConnectivityService] Check error: $e');
      }
      _updateStatus(ConnectivityStatus.offline);
      return ConnectivityStatus.offline;
    }

    _updateStatus(ConnectivityStatus.offline);
    return ConnectivityStatus.offline;
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      notifyListeners();

      if (kDebugMode) {
        debugPrint('[ConnectivityService] Status changed: ${newStatus.name}');
      }
    }
  }

  /// Start periodic connectivity check.
  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectivity();
    });

    // Initial check
    checkConnectivity();
  }

  /// Force immediate connectivity check.
  Future<ConnectivityStatus> forceCheck() async {
    return await checkConnectivity();
  }

  /// Get user-friendly message for current status.
  String get statusMessage {
    switch (_status) {
      case ConnectivityStatus.online:
        return 'Terhubung ke internet';
      case ConnectivityStatus.offline:
        return 'Tidak ada koneksi internet';
      case ConnectivityStatus.poor:
        return 'Koneksi internet tidak stabil';
    }
  }

  /// Dispose resources.
  @override
  void dispose() {
    _checkTimer?.cancel();
    _statusController.close();
    super.dispose();
  }
}
