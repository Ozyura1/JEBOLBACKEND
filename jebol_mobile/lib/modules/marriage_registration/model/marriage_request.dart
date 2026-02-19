class MarriageRequest {
  final String nikPria;
  final String nikWanita;
  final String namaPria;
  final String namaWanita;
  final String alamat;

  const MarriageRequest({
    required this.nikPria,
    required this.nikWanita,
    required this.namaPria,
    required this.namaWanita,
    required this.alamat,
  });

  Map<String, String> toFields() {
    return {
      'nik_pria': nikPria,
      'nik_wanita': nikWanita,
      'nama_pria': namaPria,
      'nama_wanita': namaWanita,
      'alamat': alamat,
    };
  }
}
