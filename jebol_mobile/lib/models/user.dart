import 'user_role.dart';

/// User model, mapping role backend ke frontend:
///   SUPER_ADMIN        => UserRole.superAdmin
///   ADMIN_KTP         => UserRole.admin1
///   ADMIN_IKD         => UserRole.admin2
///   ADMIN_PERKAWINAN  => UserRole.admin3
///   RT                => UserRole.rt
///   (lainnya/public)  => UserRole.public
class User {
  final String id;
  final String username;
  final UserRole role;
  final String? token; // For authenticated users

  User({
    required this.id,
    required this.username,
    required this.role,
    this.token,
  });

  /// Mapping string role dari backend ke enum UserRole frontend
  static UserRole parseRole(String? role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'ADMIN_KTP':
        return UserRole.admin1;
      case 'ADMIN_IKD':
        return UserRole.admin2;
      case 'ADMIN_PERKAWINAN':
        return UserRole.admin3;
      case 'RT':
        return UserRole.rt;
      // Tambahkan case baru di sini jika backend menambah role baru
      default:
        return UserRole.public;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Normalize incoming types: backend may return numeric `id`.
    final rawId = json['id'];
    final idStr = rawId == null ? '' : rawId.toString();
    final usernameStr = json['username']?.toString() ?? '';
    final roleStr = json['role']?.toString();
    final tokenStr = json['token']?.toString();

    return User(
      id: idStr,
      username: usernameStr,
      role: parseRole(roleStr),
      token: tokenStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'role': role.name, 'token': token};
  }

  User copyWith({String? id, String? username, UserRole? role, String? token}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
