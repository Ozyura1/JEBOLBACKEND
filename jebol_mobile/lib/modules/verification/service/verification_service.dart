import '../../../services/api_service.dart';

class VerificationService {
  final ApiService _apiService;

  // Backend must implement these endpoints under /api/verification/*
  static const String _listPath = '/api/verification';
  static const String _detailPath = '/api/verification';
  static const String _verifyPath = '/api/verification/verify';
  static const String _revisePath = '/api/verification/revise';

  VerificationService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> fetchList() {
    return _apiService.authGet(_listPath);
  }

  Future<Map<String, dynamic>> fetchDetail(String id) {
    return _apiService.authGet('$_detailPath/$id');
  }

  Future<Map<String, dynamic>> markValid(String id) {
    return _apiService.authPost(_verifyPath, body: {'id': id});
  }

  Future<Map<String, dynamic>> markRevisi(String id, String reason) {
    return _apiService.authPost(
      _revisePath,
      body: {'id': id, 'reason': reason},
    );
  }
}
