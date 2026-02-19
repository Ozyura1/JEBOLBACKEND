import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/routing/app_router.dart';
import 'core/error/global_error_handler.dart';
import 'core/network/session_listener.dart';
import 'core/utils/audit_logger.dart';
import 'core/hardening/hardening.dart';
// Admin module providers
import 'modules/admin_ktp/provider/admin_ktp_provider.dart';
import 'modules/admin_ikd/provider/admin_ikd_provider.dart';
import 'modules/admin_perkawinan/provider/admin_perkawinan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  if (kDebugMode) {
    AppConfig.initDevelopment();
  } else {
    AppConfig.initProduction();
  }

  // Initialize global error handler
  GlobalErrorHandler().initialize();

  // Initialize runtime protection
  final runtimeProtection = RuntimeProtection();
  await runtimeProtection.initialize();

  // Prepare connectivity and auth providers but defer heavy work until
  // after the first UI frame to avoid blocking rendering.
  final connectivityService = ConnectivityService();

  final authProvider = AuthProvider();

  // Initialize audit logging
  AuditLogger().logAuth(action: 'app_started');

  // Log app configuration
  AppLogger.info('App', 'Started with config: ${AppConfig.instance}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => AdminKtpProvider()),
        ChangeNotifierProvider(create: (_) => AdminIkdProvider()),
        ChangeNotifierProvider(create: (_) => AdminPerkawinanProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // Start non-blocking background tasks after the first frame so UI appears
  // immediately and heavy network/DNS lookups won't cause jank.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      connectivityService.startMonitoring();
      // Fire-and-forget restoreSession to populate provider without blocking
      // the first-frame rendering.
      authProvider.restoreSession();
    } catch (e) {
      if (kDebugMode) debugPrint('[Main] Post-frame init error: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppWithAuth();
  }
}

/// App wrapper that handles auth initialization.
class _AppWithAuth extends StatefulWidget {
  const _AppWithAuth();

  @override
  State<_AppWithAuth> createState() => _AppWithAuthState();
}

class _AppWithAuthState extends State<_AppWithAuth> {
  final _runtimeProtection = RuntimeProtection();

  @override
  void initState() {
    super.initState();
    // Show security warning if device is rooted (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runtimeProtection.showSecurityWarningIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SessionListener(
          authProvider: authProvider,
          child: MaterialApp.router(
            title: 'JEBOL - Jemput Bola',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey.shade50,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            routerConfig: AppRouter.createRouter(authProvider),
            debugShowCheckedModeBanner: AppConfig.instance.enableDebugBanner,
          ),
        );
      },
    );
  }
}
