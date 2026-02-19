// Localization strings for public module.
// Fully isolated from admin/auth flows.
//
// IMPORTANT: This module does NOT use app-wide localization.
// It is self-contained for complete isolation.

enum PublicLocale { id, en }

class PublicStrings {
  static Map<String, String> get(PublicLocale locale) {
    switch (locale) {
      case PublicLocale.en:
        return _en;
      case PublicLocale.id:
        return _id;
    }
  }

  static const Map<String, String> _id = {
    // App
    'app_title': 'Pendaftaran Perkawinan Online',
    'app_subtitle': 'Dinas Kependudukan dan Pencatatan Sipil',
    'language': 'Bahasa',

    // Home
    'home_welcome': 'Selamat Datang',
    'home_description':
        'Layanan pendaftaran perkawinan secara online. '
        'Silakan lengkapi formulir dengan data yang benar sesuai dokumen resmi.',
    'home_start_registration': 'Mulai Pendaftaran',
    'home_check_status': 'Cek Status Pendaftaran',
    'home_info_title': 'Informasi Penting',
    'home_info_1': 'Pastikan data sesuai dengan KTP dan KK',
    'home_info_2': 'Siapkan foto dokumen yang jelas',
    'home_info_3': 'Simpan nomor pendaftaran untuk pelacakan',

    // Form - General
    'form_title': 'Formulir Pendaftaran Perkawinan',
    'form_step': 'Langkah',
    'form_of': 'dari',
    'form_next': 'Selanjutnya',
    'form_previous': 'Sebelumnya',
    'form_submit': 'Kirim Pendaftaran',
    'form_required': 'Wajib diisi',

    // Form - Step 1: Data Pria
    'step1_title': 'Data Calon Suami',
    'field_nik': 'NIK (16 digit)',
    'field_nama_lengkap': 'Nama Lengkap (sesuai KTP)',
    'field_tempat_lahir': 'Tempat Lahir',
    'field_tanggal_lahir': 'Tanggal Lahir',
    'field_alamat': 'Alamat Lengkap',
    'field_rt': 'RT',
    'field_rw': 'RW',
    'field_kelurahan': 'Kelurahan/Desa',
    'field_kecamatan': 'Kecamatan',
    'field_agama': 'Agama',
    'field_status_kawin': 'Status Perkawinan Sebelumnya',
    'field_pekerjaan': 'Pekerjaan',
    'field_no_hp': 'Nomor HP (aktif)',

    // Form - Step 2: Data Wanita
    'step2_title': 'Data Calon Istri',

    // Form - Step 3: Data Pernikahan
    'step3_title': 'Data Pernikahan',
    'field_tanggal_nikah_rencana': 'Rencana Tanggal Pernikahan',
    'field_tempat_nikah': 'Tempat Pernikahan',
    'field_nama_wali': 'Nama Wali Nikah',
    'field_hubungan_wali': 'Hubungan Wali dengan Calon Istri',

    // Form - Step 4: Dokumen
    'step4_title': 'Unggah Dokumen',
    'doc_ktp_pria': 'KTP Calon Suami',
    'doc_ktp_wanita': 'KTP Calon Istri',
    'doc_kk_pria': 'Kartu Keluarga Calon Suami',
    'doc_kk_wanita': 'Kartu Keluarga Calon Istri',
    'doc_akta_lahir_pria': 'Akta Kelahiran Calon Suami',
    'doc_akta_lahir_wanita': 'Akta Kelahiran Calon Istri',
    'doc_surat_pengantar': 'Surat Pengantar RT/RW',
    'doc_foto_bersama': 'Pas Foto Bersama (4x6)',
    'doc_upload': 'Pilih File',
    'doc_uploaded': 'Terunggah',
    'doc_max_size': 'Maks. 2MB, format JPG/PNG/PDF',

    // Form - Step 5: Review
    'step5_title': 'Periksa Data',
    'review_confirm':
        'Saya menyatakan bahwa data yang saya isi adalah benar '
        'dan dapat dipertanggungjawabkan sesuai dengan dokumen asli.',
    'review_edit': 'Ubah',

    // Validation
    'validation_nik_invalid': 'NIK harus 16 digit angka',
    'validation_nik_checksum': 'Format NIK tidak valid',
    'validation_name_invalid': 'Nama minimal 3 karakter, tanpa angka',
    'validation_name_uppercase': 'Nama harus huruf kapital sesuai KTP',
    'validation_phone_invalid': 'Nomor HP tidak valid (08xx atau +628xx)',
    'validation_date_invalid': 'Tanggal tidak valid',
    'validation_date_future': 'Tanggal lahir tidak boleh di masa depan',
    'validation_date_too_young':
        'Usia minimal 19 tahun untuk pria, 16 tahun untuk wanita',
    'validation_address_short': 'Alamat terlalu pendek',
    'validation_required': 'Field ini wajib diisi',
    'validation_file_required': 'Dokumen wajib diunggah',
    'validation_file_too_large': 'Ukuran file melebihi batas 2MB',
    'validation_file_invalid_type': 'Format file tidak didukung',
    'validation_marriage_date_past': 'Tanggal nikah tidak boleh di masa lalu',
    'validation_marriage_date_too_soon': 'Minimal 14 hari dari sekarang',

    // Success
    'success_title': 'Pendaftaran Berhasil!',
    'success_message':
        'Permohonan pendaftaran perkawinan Anda telah diterima. '
        'Simpan nomor pendaftaran di bawah ini untuk melacak status.',
    'success_registration_number': 'Nomor Pendaftaran',
    'success_copy': 'Salin',
    'success_copied': 'Tersalin!',
    'success_next_steps': 'Langkah Selanjutnya',
    'success_step_1': 'Tunggu verifikasi dokumen (1-3 hari kerja)',
    'success_step_2': 'Anda akan dihubungi via WhatsApp/SMS',
    'success_step_3': 'Datang ke kantor Dukcapil sesuai jadwal',
    'success_back_home': 'Kembali ke Beranda',
    'success_check_status': 'Cek Status',

    // Tracking
    'tracking_title': 'Lacak Status Pendaftaran',
    'tracking_input_label': 'Masukkan Nomor Pendaftaran',
    'tracking_input_hint': 'Contoh: REG-2025-XXXXXX',
    'tracking_search': 'Cari',
    'tracking_not_found': 'Pendaftaran tidak ditemukan',
    'tracking_not_found_desc':
        'Pastikan nomor pendaftaran yang Anda masukkan sudah benar.',
    'tracking_status': 'Status',
    'tracking_submitted_at': 'Tanggal Pengajuan',
    'tracking_last_update': 'Update Terakhir',
    'tracking_timeline': 'Riwayat Status',

    // Status
    'status_pending': 'Menunggu Verifikasi',
    'status_verified': 'Dokumen Terverifikasi',
    'status_scheduled': 'Terjadwal',
    'status_completed': 'Selesai',
    'status_rejected': 'Ditolak',
    'status_revision': 'Perlu Revisi',

    // Agama
    'agama_islam': 'Islam',
    'agama_kristen': 'Kristen Protestan',
    'agama_katolik': 'Katolik',
    'agama_hindu': 'Hindu',
    'agama_buddha': 'Buddha',
    'agama_konghucu': 'Konghucu',

    // Status Kawin
    'kawin_belum': 'Belum Kawin',
    'kawin_cerai_hidup': 'Cerai Hidup',
    'kawin_cerai_mati': 'Cerai Mati',

    // Hubungan Wali
    'wali_ayah': 'Ayah Kandung',
    'wali_kakek': 'Kakek',
    'wali_saudara': 'Saudara Laki-laki',
    'wali_paman': 'Paman',
    'wali_hakim': 'Wali Hakim',

    // Errors
    'error_network':
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
    'error_server': 'Terjadi kesalahan pada server. Silakan coba lagi.',
    'error_unknown': 'Terjadi kesalahan. Silakan coba lagi.',
    'error_retry': 'Coba Lagi',

    // General
    'cancel': 'Batal',
    'ok': 'OK',
    'yes': 'Ya',
    'no': 'Tidak',
    'loading': 'Memuat...',
    'processing': 'Memproses...',
  };

  static const Map<String, String> _en = {
    // App
    'app_title': 'Online Marriage Registration',
    'app_subtitle': 'Civil Registration Office',
    'language': 'Language',

    // Home
    'home_welcome': 'Welcome',
    'home_description':
        'Online marriage registration service. '
        'Please complete the form with correct data according to official documents.',
    'home_start_registration': 'Start Registration',
    'home_check_status': 'Check Registration Status',
    'home_info_title': 'Important Information',
    'home_info_1': 'Ensure data matches your ID Card and Family Card',
    'home_info_2': 'Prepare clear document photos',
    'home_info_3': 'Save registration number for tracking',

    // Form - General
    'form_title': 'Marriage Registration Form',
    'form_step': 'Step',
    'form_of': 'of',
    'form_next': 'Next',
    'form_previous': 'Previous',
    'form_submit': 'Submit Registration',
    'form_required': 'Required',

    // Form - Step 1: Groom Data
    'step1_title': 'Groom Information',
    'field_nik': 'National ID Number (16 digits)',
    'field_nama_lengkap': 'Full Name (as per ID Card)',
    'field_tempat_lahir': 'Place of Birth',
    'field_tanggal_lahir': 'Date of Birth',
    'field_alamat': 'Full Address',
    'field_rt': 'RT',
    'field_rw': 'RW',
    'field_kelurahan': 'Village/Ward',
    'field_kecamatan': 'Sub-district',
    'field_agama': 'Religion',
    'field_status_kawin': 'Previous Marital Status',
    'field_pekerjaan': 'Occupation',
    'field_no_hp': 'Phone Number (active)',

    // Form - Step 2: Bride Data
    'step2_title': 'Bride Information',

    // Form - Step 3: Marriage Data
    'step3_title': 'Marriage Information',
    'field_tanggal_nikah_rencana': 'Planned Marriage Date',
    'field_tempat_nikah': 'Marriage Venue',
    'field_nama_wali': 'Guardian Name',
    'field_hubungan_wali': 'Guardian Relationship with Bride',

    // Form - Step 4: Documents
    'step4_title': 'Upload Documents',
    'doc_ktp_pria': 'Groom ID Card',
    'doc_ktp_wanita': 'Bride ID Card',
    'doc_kk_pria': 'Groom Family Card',
    'doc_kk_wanita': 'Bride Family Card',
    'doc_akta_lahir_pria': 'Groom Birth Certificate',
    'doc_akta_lahir_wanita': 'Bride Birth Certificate',
    'doc_surat_pengantar': 'RT/RW Reference Letter',
    'doc_foto_bersama': 'Couple Photo (4x6)',
    'doc_upload': 'Choose File',
    'doc_uploaded': 'Uploaded',
    'doc_max_size': 'Max 2MB, JPG/PNG/PDF format',

    // Form - Step 5: Review
    'step5_title': 'Review Data',
    'review_confirm':
        'I declare that the data I have filled in is correct '
        'and can be accounted for according to the original documents.',
    'review_edit': 'Edit',

    // Validation
    'validation_nik_invalid': 'National ID must be 16 digits',
    'validation_nik_checksum': 'Invalid National ID format',
    'validation_name_invalid': 'Name must be at least 3 characters, no numbers',
    'validation_name_uppercase': 'Name must be in capital letters as per ID',
    'validation_phone_invalid': 'Invalid phone number (08xx or +628xx)',
    'validation_date_invalid': 'Invalid date',
    'validation_date_future': 'Birth date cannot be in the future',
    'validation_date_too_young': 'Minimum age is 19 for groom, 16 for bride',
    'validation_address_short': 'Address is too short',
    'validation_required': 'This field is required',
    'validation_file_required': 'Document must be uploaded',
    'validation_file_too_large': 'File size exceeds 2MB limit',
    'validation_file_invalid_type': 'Unsupported file format',
    'validation_marriage_date_past': 'Marriage date cannot be in the past',
    'validation_marriage_date_too_soon': 'Minimum 14 days from today',

    // Success
    'success_title': 'Registration Successful!',
    'success_message':
        'Your marriage registration application has been received. '
        'Save the registration number below to track the status.',
    'success_registration_number': 'Registration Number',
    'success_copy': 'Copy',
    'success_copied': 'Copied!',
    'success_next_steps': 'Next Steps',
    'success_step_1': 'Wait for document verification (1-3 business days)',
    'success_step_2': 'You will be contacted via WhatsApp/SMS',
    'success_step_3': 'Visit Civil Registration Office as scheduled',
    'success_back_home': 'Back to Home',
    'success_check_status': 'Check Status',

    // Tracking
    'tracking_title': 'Track Registration Status',
    'tracking_input_label': 'Enter Registration Number',
    'tracking_input_hint': 'Example: REG-2025-XXXXXX',
    'tracking_search': 'Search',
    'tracking_not_found': 'Registration not found',
    'tracking_not_found_desc':
        'Please ensure the registration number is correct.',
    'tracking_status': 'Status',
    'tracking_submitted_at': 'Submission Date',
    'tracking_last_update': 'Last Update',
    'tracking_timeline': 'Status History',

    // Status
    'status_pending': 'Awaiting Verification',
    'status_verified': 'Documents Verified',
    'status_scheduled': 'Scheduled',
    'status_completed': 'Completed',
    'status_rejected': 'Rejected',
    'status_revision': 'Revision Required',

    // Religion
    'agama_islam': 'Islam',
    'agama_kristen': 'Protestant',
    'agama_katolik': 'Catholic',
    'agama_hindu': 'Hindu',
    'agama_buddha': 'Buddhist',
    'agama_konghucu': 'Confucian',

    // Marital Status
    'kawin_belum': 'Single',
    'kawin_cerai_hidup': 'Divorced',
    'kawin_cerai_mati': 'Widowed',

    // Guardian Relationship
    'wali_ayah': 'Biological Father',
    'wali_kakek': 'Grandfather',
    'wali_saudara': 'Brother',
    'wali_paman': 'Uncle',
    'wali_hakim': 'Court-appointed Guardian',

    // Errors
    'error_network':
        'Cannot connect to server. Please check your internet connection.',
    'error_server': 'Server error occurred. Please try again.',
    'error_unknown': 'An error occurred. Please try again.',
    'error_retry': 'Retry',

    // General
    'cancel': 'Cancel',
    'ok': 'OK',
    'yes': 'Yes',
    'no': 'No',
    'loading': 'Loading...',
    'processing': 'Processing...',
  };
}
