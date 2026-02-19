/// Exception for authentication-related errors.
///
/// Provides clear, government-grade error messages that can be understood
/// by non-technical users (pegawai).
class AuthException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  const AuthException({
    required this.message,
    required this.code,
    this.originalError,
  });

  /// Token is missing or invalid
  factory AuthException.unauthenticated({String? detail}) {
    return AuthException(
      message: detail ?? 'Sesi Anda telah berakhir. Silakan login kembali.',
      code: 'UNAUTHENTICATED',
    );
  }

  /// Token refresh failed
  factory AuthException.tokenRefreshFailed({String? detail}) {
    return AuthException(
      message: detail ?? 'Gagal memperbarui sesi. Silakan login ulang.',
      code: 'TOKEN_REFRESH_FAILED',
    );
  }

  /// Unknown role from backend - THIS IS A CRITICAL ERROR
  factory AuthException.unknownRole(String? role) {
    return AuthException(
      message:
          'Role tidak dikenal dari server: "$role". '
          'Hubungi administrator sistem.',
      code: 'UNKNOWN_ROLE',
    );
  }

  /// User not allowed to login (e.g., public user trying to login)
  factory AuthException.loginNotAllowed({String? role}) {
    return AuthException(
      message:
          'Akun dengan role "${role ?? 'tidak dikenal'}" tidak diizinkan login. '
          'Hubungi administrator jika ini kesalahan.',
      code: 'LOGIN_NOT_ALLOWED',
    );
  }

  /// Network error
  factory AuthException.networkError({dynamic error}) {
    return AuthException(
      message:
          'Tidak dapat terhubung ke server. '
          'Periksa koneksi internet Anda.',
      code: 'NETWORK_ERROR',
      originalError: error,
    );
  }

  /// Server error
  factory AuthException.serverError({String? detail, dynamic error}) {
    return AuthException(
      message: detail ?? 'Terjadi kesalahan pada server. Coba lagi nanti.',
      code: 'SERVER_ERROR',
      originalError: error,
    );
  }

  /// Invalid credentials
  factory AuthException.invalidCredentials() {
    return AuthException(
      message: 'Username atau password salah.',
      code: 'INVALID_CREDENTIALS',
    );
  }

  /// Account inactive
  factory AuthException.accountInactive() {
    return AuthException(
      message: 'Akun Anda tidak aktif. Hubungi administrator.',
      code: 'ACCOUNT_INACTIVE',
    );
  }

  @override
  String toString() => 'AuthException[$code]: $message';
}
