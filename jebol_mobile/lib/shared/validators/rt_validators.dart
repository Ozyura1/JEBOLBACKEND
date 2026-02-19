class RtValidators {
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

  static String? nomorTelp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Nomor telepon minimal 10 digit';
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

  // Dynamic validator untuk jumlah pemohon dengan minimum yang bervariasi
  static String? Function(String?) jumlahPemohon(int minimalJumlah) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Jumlah pemohon wajib diisi';
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed < minimalJumlah) {
        return 'Jumlah pemohon minimal $minimalJumlah orang';
      }
      return null;
    };
  }

  // Validator untuk usia dengan minimum yang bervariasi
  static String? Function(String?) usia(int minimalUsia) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Usia wajib diisi';
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed < minimalUsia) {
        return 'Usia minimal $minimalUsia tahun';
      }
      return null;
    };
  }
}
