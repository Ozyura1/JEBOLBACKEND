import '../../../services/api_service.dart';
import '../../../core/utils/audit_logger.dart';

/// Service for Admin Perkawinan operations.
/// Handles API communication for marriage registration management.
class AdminPerkawinanService {
  final ApiService _apiService;
  final AuditLogger _auditLogger;

  // Backend endpoints
  static const String _listPath = '/api/admin/perkawinan';
  static const String _detailPath = '/api/admin/perkawinan';
  static const String _verifyPath = '/api/admin/perkawinan';
  static const String _schedulePath = '/api/admin/perkawinan';
  static const String _rejectPath = '/api/admin/perkawinan';

  AdminPerkawinanService([ApiService? apiService])
    : _apiService = apiService ?? ApiService(),
      _auditLogger = AuditLogger();

  /// Fetch list of marriage registrations with optional filters.
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

  /// Fetch detail of a marriage registration.
  Future<Map<String, dynamic>> fetchDetail(String uuid) async {
    final result = await _apiService.authGet('$_detailPath/$uuid');

    _auditLogger.logNetwork(
      method: 'GET',
      path: '$_detailPath/$uuid',
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Verify a marriage registration (mark as verified).
  Future<Map<String, dynamic>> verify(String uuid, {String? catatan}) async {
    final body = <String, dynamic>{};
    if (catatan != null && catatan.isNotEmpty) {
      body['catatan_admin'] = catatan;
    }

    final result = await _apiService.authPost(
      '$_verifyPath/$uuid/verify',
      body: body,
    );

    _auditLogger.logSubmission(
      module: 'Perkawinan',
      action: 'verify',
      submissionId: uuid,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: '$_verifyPath/$uuid/verify',
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Schedule marriage ceremony date.
  Future<Map<String, dynamic>> schedule(
    String uuid, {
    required DateTime tanggalNikah,
    String? catatan,
  }) async {
    final body = <String, dynamic>{
      'tanggal_nikah': tanggalNikah.toIso8601String().split('T').first,
    };
    if (catatan != null && catatan.isNotEmpty) {
      body['catatan_admin'] = catatan;
    }

    final result = await _apiService.authPost(
      '$_schedulePath/$uuid/schedule',
      body: body,
    );

    _auditLogger.logSubmission(
      module: 'Perkawinan',
      action: 'schedule',
      submissionId: uuid,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: '$_schedulePath/$uuid/schedule',
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Reject a marriage registration with reason.
  Future<Map<String, dynamic>> reject(
    String uuid, {
    required String alasan,
  }) async {
    final body = <String, dynamic>{'reason': alasan};

    final result = await _apiService.authPost(
      '$_rejectPath/$uuid/reject',
      body: body,
    );

    _auditLogger.logSubmission(
      module: 'Perkawinan',
      action: 'reject',
      submissionId: uuid,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: '$_rejectPath/$uuid/reject',
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }

  /// Request revision/additional documents.
  Future<Map<String, dynamic>> requestRevision(
    String uuid, {
    required String catatan,
  }) async {
    final body = <String, dynamic>{'catatan_admin': catatan};

    final result = await _apiService.authPost(
      '$_detailPath/$uuid/revise',
      body: body,
    );

    _auditLogger.logSubmission(
      module: 'Perkawinan',
      action: 'request_revision',
      submissionId: uuid,
    );

    _auditLogger.logNetwork(
      method: 'POST',
      path: '$_detailPath/$uuid/revise',
      statusCode: result['statusCode'] as int? ?? 0,
    );

    return result;
  }
}
