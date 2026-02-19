/// IKD Submission model for admin view.
/// Represents an IKD (Identitas Kependudukan Digital) activation request from RT.
class IkdSubmission {
  final String id;
  final String nama;
  final String nomorTelp;
  final String alamat;
  final double? latitude;
  final double? longitude;
  final int jumlahPemohon;
  final String status;
  final String userId;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? scheduledAt;
  final String? scheduleNotes;
  final String? rejectionReason;

  const IkdSubmission({
    required this.id,
    required this.nama,
    required this.nomorTelp,
    required this.alamat,
    this.latitude,
    this.longitude,
    required this.jumlahPemohon,
    required this.status,
    required this.userId,
    this.createdAt,
    this.approvedAt,
    this.scheduledAt,
    this.scheduleNotes,
    this.rejectionReason,
  });

  factory IkdSubmission.fromJson(Map<String, dynamic> json) {
    return IkdSubmission(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nomorTelp: json['nomor_telp']?.toString() ?? '',
      alamat: json['alamat_manual']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      jumlahPemohon: _parseInt(json['jumlah_pemohon']),
      status: json['status']?.toString() ?? 'pending',
      userId: json['user_id']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      approvedAt: _parseDateTime(json['approved_at']),
      scheduledAt: _parseDateTime(json['scheduled_at']),
      scheduleNotes: json['schedule_notes']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String get formattedDate {
    if (createdAt == null) return '-';
    return '${createdAt!.day.toString().padLeft(2, '0')}/'
        '${createdAt!.month.toString().padLeft(2, '0')}/'
        '${createdAt!.year}';
  }

  String get formattedSchedule {
    if (scheduledAt == null) return 'Belum dijadwalkan';
    return '${scheduledAt!.day.toString().padLeft(2, '0')}/'
        '${scheduledAt!.month.toString().padLeft(2, '0')}/'
        '${scheduledAt!.year} '
        '${scheduledAt!.hour.toString().padLeft(2, '0')}:'
        '${scheduledAt!.minute.toString().padLeft(2, '0')}';
  }
}
