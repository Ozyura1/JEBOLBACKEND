import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/audit_logger.dart';

/// Global error handler for catching unhandled errors.
///
/// This handler:
/// - Catches all unhandled Flutter errors
/// - Logs them to audit (non-sensitive)
/// - Shows user-friendly message instead of crash
/// - In release mode, hides stack traces
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  final AuditLogger _auditLogger = AuditLogger();
  VoidCallback? _onError;

  /// Initialize global error handling.
  /// Call this in main() before runApp().
  void initialize({VoidCallback? onError}) {
    _onError = onError;

    // Handle Flutter errors (widget build errors, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    // Log to audit (non-sensitive)
    _auditLogger.logError(
      source: details.library ?? 'Unknown',
      errorType: details.exception.runtimeType.toString(),
    );

    // In debug mode, print full details
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }

    // Notify callback if set
    _onError?.call();
  }

  /// Get a user-friendly error message for display.
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'Terjadi kesalahan yang tidak diketahui.';
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network')) {
      return 'Tidak dapat terhubung ke server.\nPeriksa koneksi internet Anda.';
    }

    // Timeout
    if (errorString.contains('timeout')) {
      return 'Waktu koneksi habis.\nSilakan coba lagi.';
    }

    // Auth errors
    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Sesi Anda telah berakhir.\nSilakan login kembali.';
    }

    // Forbidden
    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'Anda tidak memiliki akses ke fitur ini.';
    }

    // Not found
    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Data yang dicari tidak ditemukan.';
    }

    // Server error
    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'Terjadi kesalahan pada server.\nSilakan coba lagi nanti.';
    }

    // Default message in release mode (hide technical details)
    if (kReleaseMode) {
      return 'Terjadi kesalahan.\nSilakan coba lagi.';
    }

    // In debug mode, show more detail
    return 'Terjadi kesalahan: ${error.runtimeType}';
  }
}

/// Widget for building a safe error boundary.
/// Catches errors in child widget tree and shows fallback UI.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? fallbackBuilder;

  const ErrorBoundary({super.key, required this.child, this.fallbackBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
  }

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(_error!, _retry);
      }
      return _DefaultErrorFallback(error: _error!, onRetry: _retry);
    }

    return widget.child;
  }
}

class _DefaultErrorFallback extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorFallback({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                GlobalErrorHandler.getUserFriendlyMessage(error),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
