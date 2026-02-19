enum UserRole { superAdmin, adminKtp, adminIkd, adminPerkawinan, rt }

UserRole parseRole(String role) {
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
    default:
      throw Exception('Unknown role: $role');
  }
}

extension UserRoleLabel on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.adminKtp:
        return 'Admin KTP';
      case UserRole.adminIkd:
        return 'Admin IKD';
      case UserRole.adminPerkawinan:
        return 'Admin Perkawinan';
      case UserRole.rt:
        return 'RT';
    }
  }
}
