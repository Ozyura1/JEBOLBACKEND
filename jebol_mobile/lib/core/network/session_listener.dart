import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/session_manager.dart';
import '../routing/route_paths.dart';
import '../auth/auth_provider.dart';

/// Widget that listens to global session events and handles auto-logout.
/// Wrap your MaterialApp with this to enable global session management.
class SessionListener extends StatefulWidget {
  final Widget child;
  final AuthProvider authProvider;

  const SessionListener({
    super.key,
    required this.child,
    required this.authProvider,
  });

  @override
  State<SessionListener> createState() => _SessionListenerState();
}

class _SessionListenerState extends State<SessionListener> {
  final _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _listenToSessionEvents();
  }

  void _listenToSessionEvents() {
    _sessionManager.onSessionExpired.listen((event) {
      _handleSessionExpired(event);
    });

    _sessionManager.onNetworkError.listen((event) {
      _handleNetworkError(event);
    });
  }

  void _handleSessionExpired(SessionExpiredEvent event) {
    if (!mounted) return;

    // Force logout
    widget.authProvider.logout();

    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(event.reason),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () {
            context.go(RoutePaths.login);
          },
        ),
      ),
    );

    // Navigate to login
    context.go(RoutePaths.login);
  }

  void _handleNetworkError(NetworkErrorEvent event) {
    if (!mounted) return;

    Color backgroundColor;
    switch (event.type) {
      case NetworkErrorType.noInternet:
        backgroundColor = Colors.grey[800]!;
        break;
      case NetworkErrorType.timeout:
        backgroundColor = Colors.orange;
        break;
      case NetworkErrorType.serverError:
        backgroundColor = Colors.red;
        break;
      case NetworkErrorType.unknown:
        backgroundColor = Colors.grey[700]!;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(event.message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
