import '../constants/roles.dart';
import 'route_paths.dart';

class RouteConfig {
  // Public routes that bypass AuthProvider entirely
  static const List<String> publicRoutes = [
    RoutePaths.publicMarriageRegistration,
    RoutePaths.publicMarriageStatus,
    RoutePaths.publicDashboard,
  ];

  static const List<String> publicPrefixes = [RoutePaths.publicBase];

  // Role-based access map (prefix-based)
  static const Map<UserRole, List<String>> roleRoutes = {
    UserRole.superAdmin: [
      RoutePaths.adminBase,
      RoutePaths.adminKtp,
      RoutePaths.adminKtpList,
      RoutePaths.adminIkd,
      RoutePaths.adminIkdList,
      RoutePaths.adminPerkawinan,
      RoutePaths.adminPerkawinanList,
      RoutePaths.superAdmin,
      RoutePaths.adminApproval,
      RoutePaths.adminMonitoring,
    ],
    UserRole.adminKtp: [RoutePaths.adminKtp, RoutePaths.adminKtpList],
    UserRole.adminIkd: [RoutePaths.adminIkd, RoutePaths.adminIkdList],
    UserRole.adminPerkawinan: [
      RoutePaths.adminPerkawinan,
      RoutePaths.adminPerkawinanList,
      RoutePaths.adminApproval,
    ],
    UserRole.rt: [
      RoutePaths.rtBase,
      RoutePaths.rtDashboard,
      RoutePaths.rtKtpForm,
      RoutePaths.rtIkdForm,
      RoutePaths.rtSchedule,
      RoutePaths.rtVerificationList,
      RoutePaths.rtVerificationDetail,
    ],
  };

  static bool isSystemRoute(String location) {
    return location == RoutePaths.login ||
        location == RoutePaths.unauthorized ||
        location == RoutePaths.notFound ||
        location == RoutePaths.forbidden;
  }

  static bool isPublicRoute(String location) {
    if (publicRoutes.contains(location)) return true;
    return publicPrefixes.any((prefix) => location.startsWith(prefix));
  }

  static bool canAccess(UserRole role, String location) {
    final allowedPrefixes = roleRoutes[role] ?? [];
    return allowedPrefixes.any((prefix) => location.startsWith(prefix));
  }

  static String defaultRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return RoutePaths.superAdmin;
      case UserRole.adminKtp:
        return RoutePaths.adminKtp;
      case UserRole.adminIkd:
        return RoutePaths.adminIkd;
      case UserRole.adminPerkawinan:
        return RoutePaths.adminPerkawinan;
      case UserRole.rt:
        return RoutePaths.rtDashboard;
    }
  }
}
