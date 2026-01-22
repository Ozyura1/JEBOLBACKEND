import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/user_role.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final user = authProvider.currentUser;
        final isLoggedIn = authProvider.isLoggedIn;
        final location = state.uri.toString();

        // If not logged in and not on login page, redirect to login
        if (!isLoggedIn && location != '/login') {
          return '/login';
        }

        // If logged in and on login page, redirect to home
        if (isLoggedIn && location == '/login') {
          return '/home';
        }

        // Block Public User from accessing any protected route
        if (isLoggedIn && user != null && user.role == UserRole.public) {
          return '/login';
        }

        // Role-based redirects
        if (isLoggedIn && user != null) {
          // Check if user has access to the route
          if (!_hasAccess(user.role, location)) {
            return '/home'; // Redirect to home if no access
          }
        }

        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        // Add more routes as needed
        // GoRoute(path: '/info', builder: ...),
        // GoRoute(path: '/admin1/ktp', builder: ...),
        // etc.
      ],
    );
  }

  static bool _hasAccess(UserRole role, String location) {
    // Define access rules
    final roleAccess = {
      UserRole.superAdmin: ['/home', '/super-admin'],
      UserRole.admin1: ['/home', '/admin1/ktp'],
      UserRole.admin2: ['/home', '/admin2/ikd'],
      UserRole.admin3: ['/home', '/admin3/perkawinan'],
      UserRole.rt: ['/home', '/rt/verification'],
      UserRole.public: ['/home', '/public/request', '/public/status', '/info'],
    };

    final allowedPaths = roleAccess[role] ?? [];
    return allowedPaths.any((path) => location.startsWith(path));
  }
}
