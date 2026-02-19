import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';

/// Offline banner widget that shows when there's no network connection.
class OfflineBanner extends StatelessWidget {
  final ConnectivityStatus status;
  final VoidCallback? onRetry;

  const OfflineBanner({super.key, required this.status, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (status == ConnectivityStatus.online) {
      return const SizedBox.shrink();
    }

    final isOffline = status == ConnectivityStatus.offline;
    final backgroundColor = isOffline ? Colors.red : Colors.orange;
    final message = isOffline
        ? 'Tidak ada koneksi internet'
        : 'Koneksi internet lambat';

    return Material(
      child: Container(
        width: double.infinity,
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isOffline
                      ? Icons.wifi_off
                      : Icons.signal_wifi_statusbar_connected_no_internet_4,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that automatically shows offline banner.
class ConnectivityAwareScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const ConnectivityAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  State<ConnectivityAwareScaffold> createState() =>
      _ConnectivityAwareScaffoldState();
}

class _ConnectivityAwareScaffoldState extends State<ConnectivityAwareScaffold> {
  final _connectivityService = ConnectivityService();
  ConnectivityStatus _status = ConnectivityStatus.online;

  @override
  void initState() {
    super.initState();
    _status = _connectivityService.currentStatus;
    _connectivityService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _status = status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Column(
        children: [
          OfflineBanner(
            status: _status,
            onRetry: () => _connectivityService.checkNow(),
          ),
          Expanded(child: widget.body),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      drawer: widget.drawer,
      backgroundColor: widget.backgroundColor,
    );
  }
}

/// Mixin for widgets that need to react to connectivity changes.
mixin ConnectivityAware<T extends StatefulWidget> on State<T> {
  late final ConnectivityService _connectivityService;
  ConnectivityStatus _connectivityStatus = ConnectivityStatus.online;

  ConnectivityStatus get connectivityStatus => _connectivityStatus;
  bool get isOnline => _connectivityStatus == ConnectivityStatus.online;
  bool get isOffline => _connectivityStatus == ConnectivityStatus.offline;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectivityStatus = _connectivityService.currentStatus;
    _connectivityService.statusStream.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(ConnectivityStatus status) {
    if (mounted) {
      setState(() => _connectivityStatus = status);
      onConnectivityChanged(status);
    }
  }

  /// Override this to handle connectivity changes.
  void onConnectivityChanged(ConnectivityStatus status) {
    // Override in subclass
    if (kDebugMode) {
      debugPrint('[ConnectivityAware] Status changed to: $status');
    }
  }
}
