import 'package:flutter/material.dart';
import 'screen/public_home_screen.dart';
import 'screen/public_marriage_form_screen.dart';
import 'screen/public_success_screen.dart';
import 'screen/public_tracking_screen.dart';
import 'provider/public_locale_provider.dart';

/// Public module router - COMPLETELY ISOLATED from auth flow.
///
/// This router handles all public citizen-facing routes.
/// NO authentication required. NO access to admin state.
class PublicRouter {
  /// Route names for public module.
  static const String home = '/public';
  static const String marriageForm = '/public/marriage/form';
  static const String marriageSuccess = '/public/marriage/success';
  static const String marriageTrack = '/public/marriage/track';

  /// Generate routes for public module.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const PublicHomeScreen(),
          settings: settings,
        );

      case marriageForm:
        final locale = settings.arguments as PublicLocaleProvider?;
        return MaterialPageRoute(
          builder: (_) => PublicMarriageFormScreen(initialLocale: locale),
          settings: settings,
        );

      case marriageSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        final uuid = args?['uuid'] as String? ?? '';
        final locale =
            args?['locale'] as PublicLocaleProvider? ?? PublicLocaleProvider();
        return MaterialPageRoute(
          builder: (_) =>
              PublicSuccessScreen(uuid: uuid, localeProvider: locale),
          settings: settings,
        );

      case marriageTrack:
        final args = settings.arguments;
        String? uuid;
        PublicLocaleProvider? locale;

        if (args is Map<String, dynamic>) {
          uuid = args['uuid'] as String?;
          locale = args['locale'] as PublicLocaleProvider?;
        } else if (args is PublicLocaleProvider) {
          locale = args;
        }

        return MaterialPageRoute(
          builder: (_) =>
              PublicTrackingScreen(initialUuid: uuid, initialLocale: locale),
          settings: settings,
        );

      default:
        return null;
    }
  }

  /// Check if route belongs to public module.
  static bool isPublicRoute(String? routeName) {
    if (routeName == null) return false;
    return routeName.startsWith('/public');
  }
}

/// Standalone public app - can be used as completely separate entry point.
/// Use this if you want to run the public module as a separate app.
class PublicApp extends StatelessWidget {
  const PublicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendaftaran Perkawinan Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1565C0),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1565C0),
            side: const BorderSide(color: Color(0xFF1565C0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
        ),
      ),
      initialRoute: PublicRouter.home,
      onGenerateRoute: PublicRouter.onGenerateRoute,
    );
  }
}
