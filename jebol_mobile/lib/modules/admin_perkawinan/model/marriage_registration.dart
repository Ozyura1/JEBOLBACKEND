/// Marriage Registration model for admin view.
/// Represents a public marriage registration submission.
class MarriageRegistration {
  final String id;
  final String uuid;
  final String namaPria;
  final String namWanita;
  final String nikPria;
  final String nikWanita;
  final String? noTeleponPria;
  final String? noTeleponWanita;
  final String? alamatPria;
  final String? alamatWanita;
  final String status;
  final DateTime? tanggalPengajuan;
  final DateTime? tanggalNikah;
  final String? catatan;
  final String? catatanAdmin;
  final List<String> dokumenUrls;
  final List<MarriageAuditEntry> auditTrail;

  const MarriageRegistration({
    required this.id,
    required this.uuid,
    required this.namaPria,
    required this.namWanita,
    required this.nikPria,
    required this.nikWanita,
    this.noTeleponPria,
    this.noTeleponWanita,
    this.alamatPria,
    this.alamatWanita,
    required this.status,
    this.tanggalPengajuan,
    this.tanggalNikah,
    this.catatan,
    this.catatanAdmin,
    this.dokumenUrls = const [],
    this.auditTrail = const [],
  });

  factory MarriageRegistration.fromJson(Map<String, dynamic> json) {
    return MarriageRegistration(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? json['id']?.toString() ?? '',
      namaPria:
          json['nama_pria']?.toString() ??
          json['pria']?['nama']?.toString() ??
          '-',
      namWanita:
          json['nama_wanita']?.toString() ??
          json['wanita']?['nama']?.toString() ??
          '-',
      nikPria:
          json['nik_pria']?.toString() ??
          json['pria']?['nik']?.toString() ??
          '-',
      nikWanita:
          json['nik_wanita']?.toString() ??
          json['wanita']?['nik']?.toString() ??
          '-',
      noTeleponPria:
          json['no_telepon_pria']?.toString() ??
          json['pria']?['no_telepon']?.toString(),
      noTeleponWanita:
          json['no_telepon_wanita']?.toString() ??
          json['wanita']?['no_telepon']?.toString(),
      alamatPria:
          json['alamat_pria']?.toString() ??
          json['pria']?['alamat']?.toString(),
      alamatWanita:
          json['alamat_wanita']?.toString() ??
          json['wanita']?['alamat']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      tanggalPengajuan: _parseDateTime(
        json['tanggal_pengajuan'] ?? json['created_at'],
      ),
      tanggalNikah: _parseDateTime(json['tanggal_nikah']),
      catatan: json['catatan']?.toString(),
      catatanAdmin: json['catatan_admin']?.toString(),
      dokumenUrls: _parseDocuments(json['dokumen'] ?? json['documents']),
      auditTrail: _parseAuditTrail(json['audit_trail']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String> _parseDocuments(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  static List<MarriageAuditEntry> _parseAuditTrail(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .map(
          (e) =>
              e is Map<String, dynamic> ? MarriageAuditEntry.fromJson(e) : null,
        )
        .whereType<MarriageAuditEntry>()
        .toList();
  }

  String get formattedTanggalPengajuan {
    if (tanggalPengajuan == null) return '-';
    return '${tanggalPengajuan!.day.toString().padLeft(2, '0')}/'
        '${tanggalPengajuan!.month.toString().padLeft(2, '0')}/'
        '${tanggalPengajuan!.year}';
  }

  String get formattedTanggalNikah {
    if (tanggalNikah == null) return 'Belum ditetapkan';
    return '${tanggalNikah!.day.toString().padLeft(2, '0')}/'
        '${tanggalNikah!.month.toString().padLeft(2, '0')}/'
        '${tanggalNikah!.year}';
  }

  String get pasanganNames => '$namaPria & $namWanita';
}

/// Audit trail entry for marriage registration.
class MarriageAuditEntry {
  final String id;
  final String action;
  final String? actorName;
  final String? actorRole;
  final DateTime timestamp;
  final String? notes;

  const MarriageAuditEntry({
    required this.id,
    required this.action,
    this.actorName,
    this.actorRole,
    required this.timestamp,
    this.notes,
  });

  factory MarriageAuditEntry.fromJson(Map<String, dynamic> json) {
    return MarriageAuditEntry(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      actorName:
          json['actor_name']?.toString() ?? json['actor']?['name']?.toString(),
      actorRole:
          json['actor_role']?.toString() ?? json['actor']?['role']?.toString(),
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      notes: json['notes']?.toString(),
    );
  }

  String get formattedTimestamp {
    return '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get actionLabel {
    switch (action.toUpperCase()) {
      case 'SUBMITTED':
        return 'Diajukan';
      case 'VERIFIED':
        return 'Diverifikasi';
      case 'APPROVED':
        return 'Disetujui';
      case 'REJECTED':
        return 'Ditolak';
      case 'SCHEDULED':
        return 'Dijadwalkan';
      case 'COMPLETED':
        return 'Selesai';
      case 'REVISION':
        return 'Revisi';
      default:
        return action;
    }
  }
}
