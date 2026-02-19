import '../auth/auth_provider.dart';
import 'route_config.dart';
import 'route_paths.dart';

class RouteGuard {
  static String? redirect({
    required AuthProvider auth,
    required String location,
  }) {
    // 1️⃣ Public routes → always allowed
    if (RouteConfig.isPublicRoute(location)) {
      return null;
    }

    // 2️⃣ Belum login → login
    if (!auth.isAuthenticated) {
      return location == RoutePaths.login ? null : RoutePaths.login;
    }

    final user = auth.user;
    if (user == null) {
      return RoutePaths.login;
    }

    // 3️⃣ Login tapi stay di login → lempar ke home role
    if (location == RoutePaths.login) {
      return RouteConfig.defaultRouteForRole(user.role);
    }

    // 4️⃣ Role tidak punya akses
    if (!RouteConfig.canAccess(user.role, location)) {
      return RoutePaths.forbidden;
    }

    // 5️⃣ Aman
    return null;
  }
}
