class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < min) {
        return 'Minimal $min karakter';
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(int max) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > max) {
        return 'Maksimal $max karakter';
      }
      return null;
    };
  }

  static String? numeric(String? value) {
    if (value == null || value.isEmpty) return null;
    final number = num.tryParse(value);
    if (number == null) {
      return 'Harus berupa angka';
    }
    return null;
  }

  static String? nik(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    return numeric(value);
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }
}
