import '../../../services/api_service.dart';

class MonitoringService {
  final ApiService _apiService;

  // Backend must implement monitoring endpoints for super admin
  static const String _statsPath = '/api/admin/monitoring/stats';
  static const String _auditPath = '/api/admin/monitoring/audit';

  MonitoringService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> fetchStats() {
    return _apiService.authGet(_statsPath);
  }

  Future<Map<String, dynamic>> fetchAudit() {
    return _apiService.authGet(_auditPath);
  }
}
