import '../../../services/api_service.dart';
import '../../../core/utils/audit_logger.dart';

/// Service for Admin IKD operations.
/// Handles API communication for IKD activation management.
class AdminIkdService {
  final ApiService _apiService;
  final AuditLogger _auditLogger;

  // Backend endpoints
  static const String _listPath = '/api/admin/ikd';
  static const String _detailPath = '/api/admin/ikd';
  static const String _basePath = '/api/admin/ikd';

  AdminIkdService([ApiService? apiService])
    : _apiService = apiService ?? ApiService(),
      _auditLogger = AuditLogger();

  /// Fetch list of IKD submissions with optional filters.
  Future<Map<String, dynamic>> fetchList({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }

    final result = await _apiService.authGet(_listPath, queryParams: params);

    _auditLogger.logNetwork(
      method: 'GET',
      path: _listPath,
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Fetch detail of an IKD submission.
  Future<Map<String, dynamic>> fetchDetail(String id) async {
    final result = await _apiService.authGet('$_detailPath/$id');

    _auditLogger.logNetwork(
      method: 'GET',
      path: '$_detailPath/$id',
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Verify an IKD submission.
  Future<Map<String, dynamic>> verify(String id, {String? catatan}) async {
    final path = '$_basePath/$id/approve';
    final body = <String, dynamic>{};
    if (catatan != null && catatan.isNotEmpty) {
      body['notes'] = catatan;
    }

    final result = await _apiService.authPost(path, body: body);

    _auditLogger.logSubmission(
      module: 'IKD',
      action: 'verify',
      submissionId: id,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: path,
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Schedule an IKD activation appointment.
  Future<Map<String, dynamic>> schedule(
    String id, {
    required DateTime scheduledAt,
    String? catatan,
  }) async {
    final path = '$_basePath/$id/schedule';
    final body = <String, dynamic>{
      'scheduled_at': scheduledAt.toIso8601String(),
    };
    if (catatan != null && catatan.isNotEmpty) {
      body['schedule_notes'] = catatan;
    }

    final result = await _apiService.authPost(path, body: body);

    _auditLogger.logSubmission(
      module: 'IKD',
      action: 'schedule',
      submissionId: id,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: path,
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Mark IKD as activated (completed).
  Future<Map<String, dynamic>> activate(String id, {String? catatan}) async {
    final path = '$_basePath/$id/activate';
    final body = <String, dynamic>{};
    if (catatan != null && catatan.isNotEmpty) {
      body['notes'] = catatan;
    }

    final result = await _apiService.authPost(path, body: body);

    _auditLogger.logSubmission(
      module: 'IKD',
      action: 'activate',
      submissionId: id,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: path,
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Reject an IKD submission with reason.
  Future<Map<String, dynamic>> reject(
    String id, {
    required String alasan,
  }) async {
    final path = '$_basePath/$id/reject';
    final body = <String, dynamic>{'rejection_reason': alasan};

    final result = await _apiService.authPost(path, body: body);

    _auditLogger.logSubmission(
      module: 'IKD',
      action: 'reject',
      submissionId: id,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: path,
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }
}
