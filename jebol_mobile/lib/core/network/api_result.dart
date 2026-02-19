/// Standardized API result wrapper for government-grade error handling.
///
/// Usage:
/// ```dart
/// final result = ApiResult.fromResponse(response);
/// if (result.isSuccess) {
///   // Handle data
/// } else if (result.isSessionExpired) {
///   // Force logout
/// } else {
///   // Show error message
/// }
/// ```
class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final List<dynamic> errors;
  final int statusCode;
  final bool isSessionExpired;
  final bool isNetworkError;
  final bool isServerError;
  final bool isValidationError;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.errors = const [],
    this.statusCode = 0,
    this.isSessionExpired = false,
    this.isNetworkError = false,
    this.isServerError = false,
    this.isValidationError = false,
  });

  bool get isSuccess => success && !isSessionExpired;
  bool get isError => !success;

  /// Create ApiResult from standard API response map.
  factory ApiResult.fromResponse(Map<String, dynamic> response) {
    final statusCode = response['statusCode'] as int? ?? 0;
    final success = response['success'] == true;
    final message = response['message']?.toString() ?? '';

    return ApiResult(
      success: success,
      message: message,
      data: response['data'] as T?,
      meta: response['meta'] as Map<String, dynamic>?,
      errors: (response['errors'] as List?) ?? [],
      statusCode: statusCode,
      isSessionExpired: statusCode == 401,
      isNetworkError: statusCode == 0,
      isServerError: statusCode >= 500,
      isValidationError: statusCode == 422,
    );
  }

  /// Create a success result.
  factory ApiResult.success({T? data, String message = ''}) {
    return ApiResult(
      success: true,
      message: message,
      data: data,
      statusCode: 200,
    );
  }

  /// Create a network error result.
  factory ApiResult.networkError() {
    return const ApiResult(
      success: false,
      message:
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      statusCode: 0,
      isNetworkError: true,
    );
  }

  /// Create a session expired result.
  factory ApiResult.sessionExpired() {
    return const ApiResult(
      success: false,
      message: 'Sesi Anda telah berakhir. Silakan login kembali.',
      statusCode: 401,
      isSessionExpired: true,
    );
  }

  /// Create a server error result.
  factory ApiResult.serverError() {
    return const ApiResult(
      success: false,
      message: 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
      statusCode: 500,
      isServerError: true,
    );
  }

  /// Get user-friendly error message.
  String get userMessage {
    if (isNetworkError) {
      return 'Tidak dapat terhubung ke server.\nPeriksa koneksi internet Anda.';
    }
    if (isSessionExpired) {
      return 'Sesi Anda telah berakhir.\nSilakan login kembali.';
    }
    if (isServerError) {
      return 'Terjadi kesalahan pada server.\nSilakan coba lagi nanti.';
    }
    if (isValidationError) {
      return message.isNotEmpty
          ? message
          : 'Data tidak valid. Periksa kembali input Anda.';
    }
    return message.isNotEmpty
        ? message
        : 'Terjadi kesalahan. Silakan coba lagi.';
  }

  /// Get validation errors as a map (field -> error message).
  Map<String, String> get validationErrors {
    if (!isValidationError || errors.isEmpty) return {};

    final result = <String, String>{};
    for (final error in errors) {
      if (error is Map) {
        error.forEach((key, value) {
          result[key.toString()] = value is List
              ? value.first.toString()
              : value.toString();
        });
      }
    }
    return result;
  }
}
