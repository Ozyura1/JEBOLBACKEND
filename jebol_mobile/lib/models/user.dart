import '../core/constants/roles.dart';
import '../core/auth/auth_exception.dart';

/// User model, mapping role backend ke frontend:
///   SUPER_ADMIN        => UserRole.superAdmin
///   ADMIN_KTP         => UserRole.adminKtp
///   ADMIN_IKD         => UserRole.adminIkd
///   ADMIN_PERKAWINAN  => UserRole.adminPerkawinan
///   RT                => UserRole.rt
///
/// PENTING: Role yang tidak dikenal akan menyebabkan CRASH.
/// Ini adalah desain yang disengaja untuk mencegah bug silent.
class User {
  final String id;
  final String username;
  final UserRole role;
  final String? token;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.token,
    this.isActive = true,
  });

  /// Mapping string role dari backend ke enum UserRole frontend.
  ///
  /// PENTING: Jika backend mengirim role yang tidak dikenal,
  /// fungsi ini akan THROW exception, BUKAN fallback ke public.
  /// Ini untuk mencegah bug silent dan memastikan frontend
  /// selalu sync dengan backend.
  static UserRole parseRole(String? role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'ADMIN_KTP':
        return UserRole.adminKtp;
      case 'ADMIN_IKD':
        return UserRole.adminIkd;
      case 'ADMIN_PERKAWINAN':
        return UserRole.adminPerkawinan;
      case 'RT':
        return UserRole.rt;
      case null:
        // Null role is a critical error - backend must always send role
        throw AuthException.unknownRole(role);
      default:
        // Unknown role is a critical error - do NOT fallback
        // This ensures frontend stays in sync with backend
        throw AuthException.unknownRole(role);
    }
  }

  /// Checks if this role is allowed to login via the mobile app.
  /// Only authenticated roles exist here.
  bool get canLogin => true;

  factory User.fromJson(Map<String, dynamic> json) {
  final rawId = json['id'];
  final idStr = rawId == null ? '' : rawId.toString();

  // ⬇️ FIX UTAMA: backend kirim `name`, bukan `username`
  final usernameStr =
      (json['name'] ?? json['username'] ?? '').toString();

  final roleStr = json['role']?.toString();
  final tokenStr = json['token']?.toString();

  // ⬇️ FIX UTAMA: default TRUE jika backend belum kirim
  final isActiveRaw = json['is_active'];
  final isActive = isActiveRaw == null
      ? true
      : (isActiveRaw == true ||
          isActiveRaw == 1 ||
          isActiveRaw == '1');

  return User(
    id: idStr,
    username: usernameStr,
    role: parseRole(roleStr), // tetap strict 👍
    token: tokenStr,
    isActive: isActive,
   );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role.name,
      'token': token,
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? username,
    UserRole? role,
    String? token,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
    );
  }
}
