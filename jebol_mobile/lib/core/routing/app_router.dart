import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import 'route_guard.dart';
import 'route_paths.dart';
import 'route_config.dart';
import '../../modules/auth/login_screen.dart';
import '../../screens/unauthorized_screen.dart';
import '../../screens/not_found_screen.dart';
import '../../modules/forbidden/forbidden_screen.dart';
import '../../modules/dashboards/super_admin/super_admin_dashboard.dart';
import '../../modules/dashboards/petugas/petugas_dashboard.dart';
import '../../modules/dashboards/public/public_dashboard.dart';
import '../../modules/dashboards/admin/admin_dashboard.dart';
import '../../modules/marriage_registration/screen/registration_form_screen.dart';
import '../../modules/marriage_registration/screen/status_screen.dart';
import '../../modules/rt/screen/ktp_form_screen.dart';
import '../../modules/rt/screen/ikd_form_screen.dart';
import '../../modules/rt/screen/schedule_screen.dart';
import '../../modules/verification/screen/verification_list_screen.dart';
import '../../modules/verification/screen/verification_detail_screen.dart';
import '../../modules/approval/screen/approval_screen.dart';
import '../../modules/monitoring/screen/monitoring_screen.dart';
// Admin KTP
import '../../modules/admin_ktp/screen/admin_ktp_list_screen.dart';
import '../../modules/admin_ktp/screen/admin_ktp_detail_screen.dart';
// Admin IKD
import '../../modules/admin_ikd/screen/admin_ikd_list_screen.dart';
import '../../modules/admin_ikd/screen/admin_ikd_detail_screen.dart';
// Admin Perkawinan
import '../../modules/admin_perkawinan/screen/admin_perkawinan_list_screen.dart';
import '../../modules/admin_perkawinan/screen/admin_perkawinan_detail_screen.dart';
// Public module (ISOLATED - no auth)
import '../../modules/public/screen/public_home_screen.dart';
import '../../modules/public/screen/public_marriage_form_screen.dart';
import '../../modules/public/screen/public_success_screen.dart';
import '../../modules/public/screen/public_tracking_screen.dart';
import '../../modules/public/provider/public_locale_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: RoutePaths.login,
      redirect: (context, state) async {
        final location = state.uri.toString();

        // PUBLIC ROUTES - NO AUTH REQUIRED, NO REDIRECT
        // These routes are completely isolated from auth flow
        if (location.startsWith('/public')) {
          return null; // Allow access without any auth check
        }

        // If user is authenticated and stays on login, send to role home
        if (location == RoutePaths.login && authProvider.isAuthenticated) {
          final user = authProvider.user;
          if (user != null) {
            return RouteConfig.defaultRouteForRole(user.role);
          }
        }

        // Centralized guard
        return RouteGuard.redirect(auth: authProvider, location: location);
      },
      routes: [
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.unauthorized,
          builder: (context, state) => const UnauthorizedScreen(),
        ),
        GoRoute(
          path: RoutePaths.forbidden,
          builder: (context, state) => const ForbiddenScreen(),
        ),
        // Public routes
        GoRoute(
          path: RoutePaths.publicMarriageRegistration,
          builder: (context, state) => const RegistrationFormScreen(),
        ),
        GoRoute(
          path: RoutePaths.publicMarriageStatus,
          builder: (context, state) => const MarriageStatusScreen(),
        ),
        GoRoute(
          path: RoutePaths.publicDashboard,
          builder: (context, state) => const PublicDashboard(),
        ),
        // RT routes
        GoRoute(
          path: RoutePaths.rtDashboard,
          builder: (context, state) => const PetugasDashboard(),
        ),
        GoRoute(
          path: RoutePaths.rtKtpForm,
          builder: (context, state) => const KtpFormScreen(),
        ),
        GoRoute(
          path: RoutePaths.rtIkdForm,
          builder: (context, state) => const IkdFormScreen(),
        ),
        GoRoute(
          path: RoutePaths.rtSchedule,
          builder: (context, state) => const RtScheduleScreen(),
        ),
        GoRoute(
          path: RoutePaths.rtVerificationList,
          builder: (context, state) => const VerificationListScreen(),
        ),
        GoRoute(
          path: RoutePaths.rtVerificationDetail,
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return VerificationDetailScreen(id: id);
          },
        ),
        // Admin routes
        GoRoute(
          path: RoutePaths.superAdmin,
          builder: (context, state) => const SuperAdminDashboard(),
        ),
        // Admin KTP routes
        GoRoute(
          path: RoutePaths.adminKtp,
          builder: (context, state) => const AdminKtpDashboard(),
        ),
        GoRoute(
          path: '${RoutePaths.adminKtp}/list',
          builder: (context, state) => const AdminKtpListScreen(),
        ),
        GoRoute(
          path: '${RoutePaths.adminKtp}/list/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return AdminKtpDetailScreen(id: id);
          },
        ),
        // Admin IKD routes
        GoRoute(
          path: RoutePaths.adminIkd,
          builder: (context, state) => const AdminIkdDashboard(),
        ),
        GoRoute(
          path: '${RoutePaths.adminIkd}/list',
          builder: (context, state) => const AdminIkdListScreen(),
        ),
        GoRoute(
          path: '${RoutePaths.adminIkd}/list/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return AdminIkdDetailScreen(id: id);
          },
        ),
        // Admin Perkawinan routes
        GoRoute(
          path: RoutePaths.adminPerkawinan,
          builder: (context, state) => const AdminPerkawinanDashboard(),
        ),
        GoRoute(
          path: '${RoutePaths.adminPerkawinan}/list',
          builder: (context, state) => const AdminPerkawinanListScreen(),
        ),
        GoRoute(
          path: '${RoutePaths.adminPerkawinan}/list/:uuid',
          builder: (context, state) {
            final uuid = state.pathParameters['uuid'] ?? '';
            return AdminPerkawinanDetailScreen(uuid: uuid);
          },
        ),
        GoRoute(
          path: RoutePaths.adminApproval,
          builder: (context, state) => const ApprovalScreen(),
        ),
        GoRoute(
          path: RoutePaths.adminMonitoring,
          builder: (context, state) => const MonitoringScreen(),
        ),
        // ========================================
        // PUBLIC ROUTES - COMPLETELY ISOLATED
        // NO AUTH REQUIRED - Citizen self-service
        // ========================================
        GoRoute(
          path: '/public',
          builder: (context, state) => const PublicHomeScreen(),
        ),
        GoRoute(
          path: '/public/marriage/form',
          builder: (context, state) => const PublicMarriageFormScreen(),
        ),
        GoRoute(
          path: '/public/marriage/success',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final uuid = extra?['uuid'] as String? ?? '';
            final locale =
                extra?['locale'] as PublicLocaleProvider? ??
                PublicLocaleProvider();
            return PublicSuccessScreen(uuid: uuid, localeProvider: locale);
          },
        ),
        GoRoute(
          path: '/public/marriage/track',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final uuid = extra?['uuid'] as String?;
            final locale = extra?['locale'] as PublicLocaleProvider?;
            return PublicTrackingScreen(
              initialUuid: uuid,
              initialLocale: locale,
            );
          },
        ),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }
}
