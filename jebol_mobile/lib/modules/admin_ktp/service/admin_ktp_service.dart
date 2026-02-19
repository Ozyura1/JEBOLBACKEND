import '../../../services/api_service.dart';
import '../../../core/utils/audit_logger.dart';

/// Service for Admin KTP operations.
/// Handles API communication for KTP submission management.
class AdminKtpService {
  final ApiService _apiService;
  final AuditLogger _auditLogger;

  // Backend endpoints
  static const String _listPath = '/api/admin/ktp';
  static const String _basePath = '/api/admin/ktp';

  AdminKtpService([ApiService? apiService])
    : _apiService = apiService ?? ApiService(),
      _auditLogger = AuditLogger();

  /// Fetch list of KTP submissions with optional filters.
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

  /// Fetch detail of a KTP submission.
  Future<Map<String, dynamic>> fetchDetail(String id) async {
    final path = '$_basePath/$id';
    final result = await _apiService.authGet(path);

    _auditLogger.logNetwork(
      method: 'GET',
      path: path,
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Verify a KTP submission (approve).
  Future<Map<String, dynamic>> verify(String id, {String? catatan}) async {
    final path = '$_basePath/$id/approve';
    final body = <String, dynamic>{};
    if (catatan != null && catatan.isNotEmpty) {
      body['catatan'] = catatan;
    }

    final result = await _apiService.authPost(path, body: body);

    _auditLogger.logSubmission(
      module: 'KTP',
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

  /// Schedule a KTP service appointment.
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
      module: 'KTP',
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

  /// Reject a KTP submission with reason.
  Future<Map<String, dynamic>> reject(
    String id, {
    required String alasan,
  }) async {
    final path = '$_basePath/$id/reject';
    final body = <String, dynamic>{'rejection_reason': alasan};

    final result = await _apiService.authPost(path, body: body);

    _auditLogger.logSubmission(
      module: 'KTP',
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

  /// Update status of a KTP submission.
  Future<Map<String, dynamic>> updateStatus(
    String id, {
    required String status,
    String? catatan,
  }) async {
    final path = '$_basePath/$id/status';
    final body = <String, dynamic>{'status': status};
    if (catatan != null && catatan.isNotEmpty) {
      body['catatan'] = catatan;
    }

    final result = await _apiService.authPut(path, body: body);

    _auditLogger.logStatusChange(
      module: 'KTP',
      submissionId: id,
      fromStatus: 'UNKNOWN',
      toStatus: status,
    );

    _auditLogger.logNetwork(
      method: 'PUT',
      path: path,
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }
}
