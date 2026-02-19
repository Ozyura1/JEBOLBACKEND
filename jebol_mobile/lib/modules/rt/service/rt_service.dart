import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';
import '../model/ktp_request.dart';
import '../model/ikd_request.dart';
import '../model/ktp_category.dart';

class RtService {
  final ApiService _apiService;

  // RT endpoints should be implemented by backend under /api/rt/*
  static const String _ktpSubmitPath = '/api/rt/ktp/submit';
  static const String _ikdSubmitPath = '/api/rt/ikd/submit';
  static const String _schedulePath = '/api/rt/dashboard/schedules';

  RtService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> submitKtp(KtpRequest request) async {
    // If no file, use normal POST
    if (request.attachmentFile == null) {
      return _apiService.authPost(_ktpSubmitPath, body: request.toJson());
    }

    // Use multipart for file upload
    return _submitKtpMultipart(request);
  }

  Future<Map<String, dynamic>> submitIkd(IkdRequest request) async {
    // If no file, use normal POST
    if (request.attachmentFile == null) {
      return _apiService.authPost(_ikdSubmitPath, body: request.toJson());
    }

    // Use multipart for file upload
    return _submitIkdMultipart(request);
  }

  Future<Map<String, dynamic>> _submitKtpMultipart(KtpRequest request) async {
    final token = await _apiService.token;
    final uri = Uri.parse('${_apiService.baseUrl}$_ktpSubmitPath');

    final multipartRequest = http.MultipartRequest('POST', uri);

    // Add auth header
    if (token != null) {
      multipartRequest.headers['Authorization'] = 'Bearer $token';
    }

    // Add form fields
    multipartRequest.fields['nama'] = request.nama;
    multipartRequest.fields['nomor_telp'] = request.nomorTelp;
    multipartRequest.fields['alamat_manual'] = request.alamatManual;
    multipartRequest.fields['latitude'] = request.latitude.toString();
    multipartRequest.fields['longitude'] = request.longitude.toString();
    multipartRequest.fields['jumlah_pemohon'] = request.jumlahPemohon
        .toString();
    multipartRequest.fields['kategori'] = request.kategori.value;
    multipartRequest.fields['minimal_usia'] = request.minimalUsia.toString();
    if (request.kategoriKhusus != null) {
      multipartRequest.fields['kategori_khusus'] =
          request.kategoriKhusus!.value;
    }

    // Add file
    if (request.attachmentFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          request.attachmentFile!.path,
        ),
      );
    }

    try {
      final response = await multipartRequest.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = _apiService.parseResponse(responseBody);
      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Upload gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> _submitIkdMultipart(IkdRequest request) async {
    final token = await _apiService.token;
    final uri = Uri.parse('${_apiService.baseUrl}$_ikdSubmitPath');

    final multipartRequest = http.MultipartRequest('POST', uri);

    // Add auth header
    if (token != null) {
      multipartRequest.headers['Authorization'] = 'Bearer $token';
    }

    // Add form fields
    multipartRequest.fields['nama'] = request.nama;
    multipartRequest.fields['nomor_telp'] = request.nomorTelp;
    multipartRequest.fields['alamat_manual'] = request.alamatManual;
    multipartRequest.fields['latitude'] = request.latitude.toString();
    multipartRequest.fields['longitude'] = request.longitude.toString();
    multipartRequest.fields['jumlah_pemohon'] = request.jumlahPemohon
        .toString();

    // Add file
    if (request.attachmentFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          request.attachmentFile!.path,
        ),
      );
    }

    try {
      final response = await multipartRequest.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = _apiService.parseResponse(responseBody);
      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Upload gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchSchedules() {
    return _apiService.authGet(_schedulePath);
  }
}
