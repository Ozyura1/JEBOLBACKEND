class MarriageValidators {
  static String? nik(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIK wajib diisi';
    }
    final digits = value.trim();
    if (digits.length != 16 || int.tryParse(digits) == null) {
      return 'NIK harus 16 digit angka';
    }
    return null;
  }

  static String? nama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  static String? alamat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat wajib diisi';
    }
    if (value.trim().length < 5) {
      return 'Alamat terlalu pendek';
    }
    return null;
  }
}
