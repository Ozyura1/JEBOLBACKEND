import 'dart:io';

class IkdRequest {
  final String nama;
  final String nomorTelp;
  final String alamatManual;
  final double latitude;
  final double longitude;
  final int jumlahPemohon;
  final File? attachmentFile;

  const IkdRequest({
    required this.nama,
    required this.nomorTelp,
    required this.alamatManual,
    required this.latitude,
    required this.longitude,
    required this.jumlahPemohon,
    this.attachmentFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nomor_telp': nomorTelp,
      'alamat_manual': alamatManual,
      'latitude': latitude,
      'longitude': longitude,
      'jumlah_pemohon': jumlahPemohon,
    };
  }
}
