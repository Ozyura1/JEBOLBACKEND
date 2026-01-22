enum UserRole {
  /// Mapping role backend ke frontend:
  ///   SUPER_ADMIN        => superAdmin
  ///   ADMIN_KTP         => admin1 (Pembuatan KTP)
  ///   ADMIN_IKD         => admin2 (Aktivasi IKD)
  ///   ADMIN_PERKAWINAN  => admin3 (Pencatatan Perkawinan)
  ///   RT                => rt (Rukun Tetangga)
  ///   (lainnya/public)  => public
  superAdmin,
  admin1, // Pembuatan KTP
  admin2, // Aktivasi IKD
  admin3, // Pencatatan Perkawinan
  rt, // Rukun Tetangga
  public, // No login
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin1:
        return 'Admin 1 (Pembuatan KTP)';
      case UserRole.admin2:
        return 'Admin 2 (Aktivasi IKD)';
      case UserRole.admin3:
        return 'Admin 3 (Pencatatan Perkawinan)';
      case UserRole.rt:
        return 'RT (Rukun Tetangga)';
      case UserRole.public:
        return 'Public User';
    }
  }

  bool get requiresLogin => this != UserRole.public;
}
