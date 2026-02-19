class AuthValidators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? username(String? value) {
    final error = requiredField(value, 'Username');
    if (error != null) return error;
    if (value!.trim().length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null;
  }

  static String? password(String? value) {
    final error = requiredField(value, 'Password');
    if (error != null) return error;
    if (value!.trim().length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }
}
