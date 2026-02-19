import 'auth_provider.dart';
import '../constants/roles.dart';

bool canAccess(AuthProvider auth, List<UserRole> allowedRoles) {
  if (!auth.isAuthenticated) return false;
  return allowedRoles.contains(auth.user!.role);
}
