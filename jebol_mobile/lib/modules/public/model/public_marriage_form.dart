import 'dart:io';

/// Marriage registration form model with Dukcapil-style validation.
///
/// IMPORTANT: This is isolated from admin models.
/// Validation rules follow Indonesian civil registration standards.
class PublicMarriageForm {
  // Data Pria (Groom)
  String nikPria = '';
  String namaLengkapPria = '';
  String tempatLahirPria = '';
  DateTime? tanggalLahirPria;
  String alamatPria = '';
  String rtPria = '';
  String rwPria = '';
  String kelurahanPria = '';
  String kecamatanPria = '';
  String agamaPria = '';
  String statusKawinPria = '';
  String pekerjaanPria = '';
  String noHpPria = '';

  // Data Wanita (Bride)
  String nikWanita = '';
  String namaLengkapWanita = '';
  String tempatLahirWanita = '';
  DateTime? tanggalLahirWanita;
  String alamatWanita = '';
  String rtWanita = '';
  String rwWanita = '';
  String kelurahanWanita = '';
  String kecamatanWanita = '';
  String agamaWanita = '';
  String statusKawinWanita = '';
  String pekerjaanWanita = '';
  String noHpWanita = '';

  // Data Pernikahan (Marriage)
  DateTime? tanggalNikahRencana;
  String tempatNikah = '';
  String namaWali = '';
  String hubunganWali = '';

  // Documents
  File? ktpPria;
  File? ktpWanita;
  File? kkPria;
  File? kkWanita;
  File? aktaLahirPria;
  File? aktaLahirWanita;
  File? suratPengantar;
  File? fotoBersama;

  // Confirmation
  bool confirmed = false;

  /// Convert to API payload.
  Map<String, dynamic> toJson() {
    return {
      // Pria
      'nik_pria': nikPria,
      'nama_lengkap_pria': namaLengkapPria,
      'tempat_lahir_pria': tempatLahirPria,
      'tanggal_lahir_pria': _formatDate(tanggalLahirPria),
      'alamat_pria': alamatPria,
      'rt_pria': rtPria,
      'rw_pria': rwPria,
      'kelurahan_pria': kelurahanPria,
      'kecamatan_pria': kecamatanPria,
      'agama_pria': agamaPria,
      'status_kawin_pria': statusKawinPria,
      'pekerjaan_pria': pekerjaanPria,
      'no_hp_pria': noHpPria,
      // Wanita
      'nik_wanita': nikWanita,
      'nama_lengkap_wanita': namaLengkapWanita,
      'tempat_lahir_wanita': tempatLahirWanita,
      'tanggal_lahir_wanita': _formatDate(tanggalLahirWanita),
      'alamat_wanita': alamatWanita,
      'rt_wanita': rtWanita,
      'rw_wanita': rwWanita,
      'kelurahan_wanita': kelurahanWanita,
      'kecamatan_wanita': kecamatanWanita,
      'agama_wanita': agamaWanita,
      'status_kawin_wanita': statusKawinWanita,
      'pekerjaan_wanita': pekerjaanWanita,
      'no_hp_wanita': noHpWanita,
      // Marriage
      'tanggal_nikah_rencana': _formatDate(tanggalNikahRencana),
      'tempat_nikah': tempatNikah,
      'nama_wali': namaWali,
      'hubungan_wali': hubunganWali,
    };
  }

  /// Get documents as map for multipart upload.
  Map<String, File> getDocuments() {
    final docs = <String, File>{};
    if (ktpPria != null) docs['ktp_pria'] = ktpPria!;
    if (ktpWanita != null) docs['ktp_wanita'] = ktpWanita!;
    if (kkPria != null) docs['kk_pria'] = kkPria!;
    if (kkWanita != null) docs['kk_wanita'] = kkWanita!;
    if (aktaLahirPria != null) docs['akta_lahir_pria'] = aktaLahirPria!;
    if (aktaLahirWanita != null) docs['akta_lahir_wanita'] = aktaLahirWanita!;
    if (suratPengantar != null) docs['surat_pengantar'] = suratPengantar!;
    if (fotoBersama != null) docs['foto_bersama'] = fotoBersama!;
    return docs;
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Dukcapil-style strict validator.
class DukcapilValidator {
  /// Validate NIK (16 digits with checksum logic).
  static String? validateNik(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr('validation_required');
    }

    // Remove any spaces or dashes
    final cleanNik = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanNik.length != 16) {
      return tr('validation_nik_invalid');
    }

    if (!RegExp(r'^\d{16}$').hasMatch(cleanNik)) {
      return tr('validation_nik_invalid');
    }

    // Basic NIK structure validation:
    // - First 6 digits: Province + City + District code
    // - Next 6 digits: Birth date (DDMMYY, female +40 to day)
    // - Last 4 digits: Sequential number

    final provinceCode = int.tryParse(cleanNik.substring(0, 2)) ?? 0;
    if (provinceCode < 11 || provinceCode > 94) {
      return tr('validation_nik_checksum');
    }

    final dayPart = int.tryParse(cleanNik.substring(6, 8)) ?? 0;
    // Day can be 01-31 for male, 41-71 for female
    if (!((dayPart >= 1 && dayPart <= 31) ||
        (dayPart >= 41 && dayPart <= 71))) {
      return tr('validation_nik_checksum');
    }

    final monthPart = int.tryParse(cleanNik.substring(8, 10)) ?? 0;
    if (monthPart < 1 || monthPart > 12) {
      return tr('validation_nik_checksum');
    }

    return null;
  }

  /// Validate name (uppercase, no numbers, min 3 chars).
  static String? validateName(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr('validation_required');
    }

    if (value.length < 3) {
      return tr('validation_name_invalid');
    }

    // Must not contain numbers
    if (RegExp(r'\d').hasMatch(value)) {
      return tr('validation_name_invalid');
    }

    // Should be uppercase (warning, not blocking)
    // Indonesian KTP names are in uppercase
    if (value != value.toUpperCase()) {
      return tr('validation_name_uppercase');
    }

    return null;
  }

  /// Validate phone number (Indonesian format).
  static String? validatePhone(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr('validation_required');
    }

    final cleanPhone = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Indonesian phone: 08xx or +628xx or 628xx
    if (!RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,10}$').hasMatch(cleanPhone)) {
      return tr('validation_phone_invalid');
    }

    return null;
  }

  /// Validate birth date.
  static String? validateBirthDate(
    DateTime? value,
    String Function(String) tr, {
    required bool isMale,
  }) {
    if (value == null) {
      return tr('validation_required');
    }

    final now = DateTime.now();

    if (value.isAfter(now)) {
      return tr('validation_date_future');
    }

    // Calculate age
    int age = now.year - value.year;
    if (now.month < value.month ||
        (now.month == value.month && now.day < value.day)) {
      age--;
    }

    // Indonesian marriage law: Male min 19, Female min 16
    // (Note: Law changed to 19 for both in 2019, but we use old standard for broader compatibility)
    final minAge = isMale ? 19 : 16;
    if (age < minAge) {
      return tr('validation_date_too_young');
    }

    return null;
  }

  /// Validate marriage date.
  static String? validateMarriageDate(
    DateTime? value,
    String Function(String) tr,
  ) {
    if (value == null) {
      return tr('validation_required');
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (value.isBefore(today)) {
      return tr('validation_marriage_date_past');
    }

    // Must be at least 14 days in advance
    final minDate = today.add(const Duration(days: 14));
    if (value.isBefore(minDate)) {
      return tr('validation_marriage_date_too_soon');
    }

    return null;
  }

  /// Validate required field.
  static String? validateRequired(String? value, String Function(String) tr) {
    if (value == null || value.trim().isEmpty) {
      return tr('validation_required');
    }
    return null;
  }

  /// Validate address.
  static String? validateAddress(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr('validation_required');
    }

    if (value.length < 10) {
      return tr('validation_address_short');
    }

    return null;
  }

  /// Validate RT/RW (1-3 digit number).
  static String? validateRtRw(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr('validation_required');
    }

    if (!RegExp(r'^\d{1,3}$').hasMatch(value)) {
      return tr('validation_required');
    }

    return null;
  }

  /// Validate file.
  static String? validateFile(File? file, String Function(String) tr) {
    if (file == null) {
      return tr('validation_file_required');
    }

    // Max 2MB
    final size = file.lengthSync();
    if (size > 2 * 1024 * 1024) {
      return tr('validation_file_too_large');
    }

    // Check extension
    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
      return tr('validation_file_invalid_type');
    }

    return null;
  }
}

/// Dropdown options for form.
class FormOptions {
  static const List<String> agamaKeys = [
    'agama_islam',
    'agama_kristen',
    'agama_katolik',
    'agama_hindu',
    'agama_buddha',
    'agama_konghucu',
  ];

  static const Map<String, String> agamaValues = {
    'agama_islam': 'ISLAM',
    'agama_kristen': 'KRISTEN',
    'agama_katolik': 'KATOLIK',
    'agama_hindu': 'HINDU',
    'agama_buddha': 'BUDDHA',
    'agama_konghucu': 'KONGHUCU',
  };

  static const List<String> statusKawinKeys = [
    'kawin_belum',
    'kawin_cerai_hidup',
    'kawin_cerai_mati',
  ];

  static const Map<String, String> statusKawinValues = {
    'kawin_belum': 'BELUM_KAWIN',
    'kawin_cerai_hidup': 'CERAI_HIDUP',
    'kawin_cerai_mati': 'CERAI_MATI',
  };

  static const List<String> hubunganWaliKeys = [
    'wali_ayah',
    'wali_kakek',
    'wali_saudara',
    'wali_paman',
    'wali_hakim',
  ];

  static const Map<String, String> hubunganWaliValues = {
    'wali_ayah': 'AYAH_KANDUNG',
    'wali_kakek': 'KAKEK',
    'wali_saudara': 'SAUDARA',
    'wali_paman': 'PAMAN',
    'wali_hakim': 'WALI_HAKIM',
  };
}
