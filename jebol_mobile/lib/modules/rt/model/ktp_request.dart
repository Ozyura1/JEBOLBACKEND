import 'dart:io';
import 'ktp_category.dart';

class KtpRequest {
  final KtpCategory kategori;
  final KhususCategory? kategoriKhusus;
  final int minimalUsia;
  final String nama;
  final String nomorTelp;
  final String alamatManual;
  final double latitude;
  final double longitude;
  final int jumlahPemohon;
  final File? attachmentFile;

  const KtpRequest({
    required this.kategori,
    this.kategoriKhusus,
    required this.minimalUsia,
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
      'kategori': kategori.value,
      'kategori_khusus': kategoriKhusus?.value,
      'minimal_usia': minimalUsia,
      'nama': nama,
      'nomor_telp': nomorTelp,
      'alamat_manual': alamatManual,
      'latitude': latitude,
      'longitude': longitude,
      'jumlah_pemohon': jumlahPemohon,
    };
  }
}
