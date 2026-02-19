import '../../../services/api_service.dart';

class ApprovalService {
  final ApiService _apiService;

  // Backend must implement these endpoints under /api/admin/perkawinan/*
  static const String _listPath = '/api/admin/perkawinan';
  static const String _approvePath = '/api/admin/perkawinan';
  static const String _rejectPath = '/api/admin/perkawinan';

  ApprovalService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> fetchList() {
    return _apiService.authGet(_listPath);
  }

  Future<Map<String, dynamic>> approve(String uuid, String tanggalNikah) {
    return _apiService.authPost(
      '$_approvePath/$uuid/verify',
      body: {'tanggal_nikah': tanggalNikah},
    );
  }

  Future<Map<String, dynamic>> reject(String uuid, String reason) {
    return _apiService.authPost(
      '$_rejectPath/$uuid/reject',
      body: {'reason': reason},
    );
  }
}
